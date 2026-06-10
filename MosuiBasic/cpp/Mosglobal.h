#ifndef MOSGLOBAL_H
#define MOSGLOBAL_H

#include <QtCore/QtGlobal> 
// 全局宏定义
// 静态库：无需导入/导出
#if defined(MOSUIBASIC_STATIC_LIBRARY)
#define MOSUIBASIC_EXPORT
// 动态库构建：导出符号
#elif defined(MOSUIBASIC_LIBRARY) || defined(MosuiBasic_EXPORTS)
#define MOSUIBASIC_EXPORT Q_DECL_EXPORT
// 动态库使用：导入符号
#else
#define MOSUIBASIC_EXPORT Q_DECL_IMPORT
#endif





#endif// MOSGLOBAL_H
