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












#endif // MOSDEFINITIONS_H