#ifndef MOSGLOBAL_H
#define MOSGLOBAL_H

#include <QtCore/QtGlobal> 
// 全局宏定义
#if defined(MOSUIBASIC_LIBRARY)
#define MOSUIBASIC_EXPORT Q_DECL_EXPORT
#else
#define MOSUIBASIC_EXPORT Q_DECL_IMPORT
#endif





#endif// MOSGLOBAL_H