#include "ring_buffer.h"

#include <algorithm>
#include <cstring>
#include <stdexcept>
#include <utility>

namespace tpinv {

RingBuffer::RingBuffer() = default;

RingBuffer::RingBuffer(size_type capacity)
    : buffer_(roundUpPowerOfTwo(capacity)),
      mask_(buffer_.empty() ? 0 : buffer_.size() - 1)
{
}

RingBuffer::RingBuffer(std::initializer_list<value_type> values)
    : RingBuffer(values.size())
{
    push(values);
}

bool RingBuffer::empty() const noexcept
{
    return size_ == 0;
}

bool RingBuffer::full() const noexcept
{
    return size_ == capacity();
}

RingBuffer::size_type RingBuffer::size() const noexcept
{
    return size_;
}

RingBuffer::size_type RingBuffer::capacity() const noexcept
{
    return buffer_.size();
}

RingBuffer::size_type RingBuffer::available() const noexcept
{
    return capacity() - size_;
}

void RingBuffer::clear() noexcept
{
    head_ = 0;
    tail_ = 0;
    size_ = 0;
}

void RingBuffer::reserve(size_type requestedCapacity)
{
    if (requestedCapacity <= capacity())
        return;

    RingBuffer next(requestedCapacity);
    copyOut(next.buffer_.data(), 0, size_);
    next.size_ = size_;
    next.tail_ = next.wrap(size_);
    swap(next);
}

void RingBuffer::resizeCapacity(size_type requestedCapacity)
{
    RingBuffer next(requestedCapacity);
    const size_type keep = std::min(size_, next.capacity());
    const size_type first = size_ - keep;

    copyOut(next.buffer_.data(), first, keep);
    next.size_ = keep;
    next.tail_ = next.wrap(keep);
    swap(next);
}

void RingBuffer::swap(RingBuffer& other) noexcept
{
    using std::swap;
    swap(buffer_, other.buffer_);
    swap(head_, other.head_);
    swap(tail_, other.tail_);
    swap(size_, other.size_);
    swap(mask_, other.mask_);
}

RingBuffer::reference RingBuffer::front()
{
    ensureNotEmpty();
    return buffer_[head_];
}

RingBuffer::const_reference RingBuffer::front() const
{
    ensureNotEmpty();
    return buffer_[head_];
}

RingBuffer::reference RingBuffer::back()
{
    ensureNotEmpty();
    return buffer_[wrap(tail_ - 1)];
}

RingBuffer::const_reference RingBuffer::back() const
{
    ensureNotEmpty();
    return buffer_[wrap(tail_ - 1)];
}

RingBuffer::reference RingBuffer::operator[](size_type index) noexcept
{
    return buffer_[wrap(head_ + index)];
}

RingBuffer::const_reference RingBuffer::operator[](size_type index) const noexcept
{
    return buffer_[wrap(head_ + index)];
}

RingBuffer::reference RingBuffer::at(size_type index)
{
    if (index >= size_)
        throw std::out_of_range("RingBuffer index out of range");
    return (*this)[index];
}

RingBuffer::const_reference RingBuffer::at(size_type index) const
{
    if (index >= size_)
        throw std::out_of_range("RingBuffer index out of range");
    return (*this)[index];
}

bool RingBuffer::tryPush(value_type value)
{
    if (full())
        return false;

    buffer_[tail_] = value;
    advanceTail();
    return true;
}

void RingBuffer::pushOverwrite(value_type value)
{
    if (capacity() == 0)
        return;

    if (full())
        advanceHead();
    buffer_[tail_] = value;
    advanceTail();
}

RingBuffer::size_type RingBuffer::push(const_pointer data, size_type count)
{
    if (!data || count == 0)
        return 0;

    const size_type writable = std::min(count, available());
    if (writable == 0)
        return 0;

    const size_type first = std::min(writable, contiguousWriteSize());
    std::memmove(buffer_.data() + tail_, data, first);

    const size_type second = writable - first;
    if (second > 0) {
        std::memmove(buffer_.data(), data + first, second);
    }

    tail_ = wrap(tail_ + writable);
    size_ += writable;
    return writable;
}

RingBuffer::size_type RingBuffer::push(std::initializer_list<value_type> values)
{
    return push(values.begin(), values.size());
}

RingBuffer::size_type RingBuffer::pushOverwrite(const_pointer data, size_type count)
{
    if (!data || count == 0 || capacity() == 0)
        return 0;

    if (count >= capacity()) {
        data += count - capacity();
        count = capacity();
        clear();
    } else {
        const size_type overflow = count > available() ? count - available() : 0;
        consume(overflow);
    }

    return push(data, count);
}

bool RingBuffer::pop(reference out)
{
    if (empty())
        return false;

    out = buffer_[head_];
    advanceHead();
    return true;
}

std::optional<RingBuffer::value_type> RingBuffer::pop()
{
    if (empty())
        return std::nullopt;

    const value_type value = buffer_[head_];
    advanceHead();
    return value;
}

RingBuffer::size_type RingBuffer::pop(pointer out, size_type count)
{
    if (!out || count == 0)
        return 0;

    const size_type readable = std::min(count, size_);
    copyOut(out, 0, readable);
    consume(readable);
    return readable;
}

RingBuffer::size_type RingBuffer::peek(pointer out, size_type count, size_type offset) const noexcept
{
    if (!out || count == 0 || offset >= size_)
        return 0;

    const size_type readable = std::min(count, size_ - offset);
    copyOut(out, offset, readable);
    return readable;
}

void RingBuffer::consume(size_type count) noexcept
{
    const size_type n = std::min(count, size_);
    head_ = wrap(head_ + n);
    size_ -= n;
    if (size_ == 0)
        tail_ = head_;
}

RingBuffer::Block RingBuffer::contiguousWriteBlock() noexcept
{
    if (full() || capacity() == 0)
        return {nullptr, 0};

    return {buffer_.data() + tail_, contiguousWriteSize()};
}

RingBuffer::ConstBlock RingBuffer::contiguousReadBlock() const noexcept
{
    if (empty())
        return {nullptr, 0};

    return {buffer_.data() + head_, contiguousReadSize(head_)};
}

void RingBuffer::commitWrite(size_type count) noexcept
{
    const size_type n = std::min(count, contiguousWriteSize());
    tail_ = wrap(tail_ + n);
    size_ += n;
}

RingBuffer::size_type RingBuffer::roundUpPowerOfTwo(size_type value) noexcept
{
    if (value <= 1)
        return value;

    --value;
    for (size_type shift = 1; shift < sizeof(size_type) * 8; shift <<= 1)
        value |= value >> shift;
    return value + 1;
}

RingBuffer::size_type RingBuffer::wrap(size_type index) const noexcept
{
    return capacity() == 0 ? 0 : (index & mask_);
}

RingBuffer::size_type RingBuffer::contiguousReadSize(size_type start) const noexcept
{
    if (size_ == 0)
        return 0;

    const size_type contiguous = tail_ > start
            ? tail_ - start
            : capacity() - start;
    return std::min(contiguous, size_);
}

RingBuffer::size_type RingBuffer::contiguousWriteSize() const noexcept
{
    if (full() || capacity() == 0)
        return 0;

    const size_type contiguous = tail_ >= head_
            ? capacity() - tail_
            : head_ - tail_;
    return std::min(contiguous, available());
}

void RingBuffer::copyOut(pointer dst, size_type offset, size_type count) const noexcept
{
    if (!dst || count == 0 || capacity() == 0)
        return;

    const size_type start = wrap(head_ + offset);
    const size_type first = std::min(count, capacity() - start);
    std::memmove(dst, buffer_.data() + start, first);

    const size_type second = count - first;
    if (second > 0)
        std::memmove(dst + first, buffer_.data(), second);
}

void RingBuffer::advanceTail() noexcept
{
    tail_ = wrap(tail_ + 1);
    ++size_;
}

void RingBuffer::advanceHead() noexcept
{
    head_ = wrap(head_ + 1);
    --size_;
    if (size_ == 0)
        tail_ = head_;
}

void RingBuffer::ensureNotEmpty() const
{
    if (empty())
        throw std::out_of_range("RingBuffer is empty");
}

void swap(RingBuffer& lhs, RingBuffer& rhs) noexcept
{
    lhs.swap(rhs);
}

} // namespace tpinv
