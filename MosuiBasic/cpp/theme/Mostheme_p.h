#ifndef MOSTTHEME_P_H
#define MOSTTHEME_P_H

#include "Mostheme.h"





class MosThemePrivate
{
public:
    Q_DECLARE_PUBLIC(MosTheme);
    MosThemePrivate(MosTheme *q) : q_ptr(q) { };
    MosTheme *q_ptr { nullptr };


};




#endif // MOSTTHEME_P_H