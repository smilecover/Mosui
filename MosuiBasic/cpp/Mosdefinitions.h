#ifndef MOSDEFINITIONS_H
#define MOSDEFINITIONS_H\

// 声明只读属性
#define MOSUI_PROPERTY_READONLY(type, name) \
    Q_PROPERTY(type name READ name NOTIFY name##Changed FINAL) \
public: \
    type name() const { return m_##name; } \
    Q_SIGNALS: \
    void name##Changed(); \
private: \
    type m_##name;

// 声明一般属性并初始化 
#define MOSUI_PROPERTY_INIT(type, get, set, init_value) \
private:\
    Q_PROPERTY(type get READ get WRITE set NOTIFY get##Changed FINAL) \
public: \
    type get() const { return m_##get; } \
    void set(const type &t) { if (t != m_##get) { m_##get = t; emit get##Changed(); } } \
Q_SIGNAL void get##Changed(); \
private: \
    type m_##get{init_value};











#endif // MOSDEFINITIONS_H