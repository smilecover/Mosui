#ifndef TPINV_RING_BUFFER_H
#define TPINV_RING_BUFFER_H

#include <cstddef>
#include <cstdint>
#include <initializer_list>
#include <optional>
#include <utility>
#include <vector>

namespace tpinv {

class RingBuffer
{
public:
    using value_type = std::uint8_t;
    using size_type = std::size_t;
    using reference = value_type&;
    using const_reference = const value_type&;
    using pointer = value_type*;
    using const_pointer = const value_type*;
    using Block = std::pair<pointer, size_type>;
    using ConstBlock = std::pair<const_pointer, size_type>;

    RingBuffer();
    explicit RingBuffer(size_type capacity);
    RingBuffer(std::initializer_list<value_type> values);

    [[nodiscard]] bool empty() const noexcept;
    [[nodiscard]] bool full() const noexcept;
    [[nodiscard]] size_type size() const noexcept;
    [[nodiscard]] size_type capacity() const noexcept;
    [[nodiscard]] size_type available() const noexcept;

    void clear() noexcept;
    void reserve(size_type requestedCapacity);
    void resizeCapacity(size_type requestedCapacity);
    void swap(RingBuffer& other) noexcept;

    [[nodiscard]] reference front();
    [[nodiscard]] const_reference front() const;
    [[nodiscard]] reference back();
    [[nodiscard]] const_reference back() const;

    [[nodiscard]] reference operator[](size_type index) noexcept;
    [[nodiscard]] const_reference operator[](size_type index) const noexcept;
    [[nodiscard]] reference at(size_type index);
    [[nodiscard]] const_reference at(size_type index) const;

    bool tryPush(value_type value);
    void pushOverwrite(value_type value);
    size_type push(const_pointer data, size_type count);
    size_type push(std::initializer_list<value_type> values);
    size_type pushOverwrite(const_pointer data, size_type count);

    bool pop(reference out);
    [[nodiscard]] std::optional<value_type> pop();
    size_type pop(pointer out, size_type count);
    size_type peek(pointer out, size_type count, size_type offset = 0) const noexcept;

    void consume(size_type count) noexcept;
    [[nodiscard]] Block contiguousWriteBlock() noexcept;
    [[nodiscard]] ConstBlock contiguousReadBlock() const noexcept;
    void commitWrite(size_type count) noexcept;

private:
    [[nodiscard]] static size_type roundUpPowerOfTwo(size_type value) noexcept;

    [[nodiscard]] size_type wrap(size_type index) const noexcept;
    [[nodiscard]] size_type contiguousReadSize(size_type start) const noexcept;
    [[nodiscard]] size_type contiguousWriteSize() const noexcept;
    void copyOut(pointer dst, size_type offset, size_type count) const noexcept;
    void advanceTail() noexcept;
    void advanceHead() noexcept;
    void ensureNotEmpty() const;

    std::vector<value_type> buffer_;
    size_type head_ = 0;
    size_type tail_ = 0;
    size_type size_ = 0;
    size_type mask_ = 0;
};

void swap(RingBuffer& lhs, RingBuffer& rhs) noexcept;

} // namespace tpinv

#endif // TPINV_RING_BUFFER_H
