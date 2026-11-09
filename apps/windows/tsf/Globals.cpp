// THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF
// ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
// PARTICULAR PURPOSE.
//
// Copyright (c) Microsoft Corporation. All rights reserved

#include "Private.h"
#include "resource.h"
#include "BaseWindow.h"
#include "define.h"
#include "SampleIMEBaseStructure.h"

namespace Global {
HINSTANCE dllInstanceHandle;

LONG dllRefCount = -1;

CRITICAL_SECTION CS;
HFONT defaultlFontHandle;				// Global font object we use everywhere

//---------------------------------------------------------------------
// SampleIME CLSID
//---------------------------------------------------------------------
// {D2291A80-84D8-4641-9AB2-BDD1472C846B}
extern const CLSID SampleIMECLSID = { 0xd22422b6, 0x4c68, 0x45c2, { 0xa1, 0x20, 0xbf, 0x91, 0x6a, 0x57, 0xc7, 0x8e } };

//---------------------------------------------------------------------
// Profile GUID
//---------------------------------------------------------------------
// {83955C0E-2C09-47a5-BCF3-F2B98E11EE8B}
extern const GUID SampleIMEGuidProfile = { 0xd3ffee35, 0xc004, 0x41eb, { 0xa0, 0x74, 0xfa, 0x8d, 0x27, 0xec, 0x3f, 0xf0 } };

//---------------------------------------------------------------------
// PreserveKey GUID
//---------------------------------------------------------------------
// {4B62B54B-F828-43B5-9095-A96DF9CBDF38}
extern const GUID SampleIMEGuidImeModePreserveKey = { 0x6cdacf9f, 0xc2d7, 0x4eb8, { 0xa3, 0xed, 0x7d, 0x53, 0x53, 0x68, 0x65, 0xfe } };

// {5A08D6C4-4563-4E46-8DDB-65E75C4E73A3}
extern const GUID SampleIMEGuidDoubleSingleBytePreserveKey = { 0x8f646d41, 0xa209, 0x476c, { 0x96, 0xef, 0x8b, 0xa0, 0x0b, 0x6e, 0xd5, 0x75 } };

// {175F062E-B961-4AED-A3DF-59F78A02862D}
extern const GUID SampleIMEGuidPunctuationPreserveKey = { 0x2a7387c4, 0x666f, 0x46b7, { 0xaa, 0xe6, 0xe8, 0x52, 0xed, 0x22, 0x2b, 0x26 } };

//---------------------------------------------------------------------
// Compartments
//---------------------------------------------------------------------
// {101011C5-CF72-4F0C-A515-153019593F10}
extern const GUID SampleIMEGuidCompartmentDoubleSingleByte = { 0xba6f4549, 0xf529, 0x498a, { 0xb8, 0xb0, 0x10, 0x12, 0xd8, 0xbd, 0x73, 0x21 } };

// {DD321BCC-A7F8-4561-9B61-9B3508C9BA97}
extern const GUID SampleIMEGuidCompartmentPunctuation = { 0x16e1bc18, 0x1371, 0x4799, { 0xbb, 0xb3, 0xb3, 0x2c, 0x6e, 0xe2, 0xa0, 0x4e } };


//---------------------------------------------------------------------
// LanguageBars
//---------------------------------------------------------------------

// {89BE500C-9462-4070-9DB0-B467BB051327}
extern const GUID SampleIMEGuidLangBarIMEMode = { 0x76f8e8a8, 0x8191, 0x4262, { 0x8c, 0x41, 0xec, 0x84, 0x32, 0x7d, 0x73, 0x7d } };

// {6A11D9DE-46DB-455B-A257-2EB615746BF4}
extern const GUID SampleIMEGuidLangBarDoubleSingleByte = { 0x7147f6f3, 0xd78f, 0x4b03, { 0x99, 0xd6, 0xdf, 0x96, 0x0d, 0x9b, 0x3e, 0x82 } };

// {F29C731A-A51E-49FB-8A3C-EE51752912E2}
extern const GUID SampleIMEGuidLangBarPunctuation = { 0xb710c980, 0x67a3, 0x47bc, { 0xb5, 0xc6, 0x57, 0x51, 0xd4, 0xf1, 0xc1, 0x56 } };

// {4C802E2C-8140-4436-A5E5-F7C544EBC9CD}
extern const GUID SampleIMEGuidDisplayAttributeInput = { 0x89285724, 0x8992, 0x4c32, { 0xac, 0x05, 0x64, 0xa2, 0x9a, 0x64, 0xd8, 0x31 } };

// {9A1CC683-F2A7-4701-9C6E-2DA69A5CD474}
extern const GUID SampleIMEGuidDisplayAttributeConverted = { 0x5f75bdb0, 0xbe28, 0x4924, { 0x9e, 0x1e, 0x01, 0xd4, 0x23, 0x6f, 0xa5, 0xef } };


//---------------------------------------------------------------------
// UI element
//---------------------------------------------------------------------

// {84B0749F-8DE7-4732-907A-3BCB150A01A8}
extern const GUID SampleIMEGuidCandUIElement = { 0x8f8ed9db, 0xb4f3, 0x40c8, { 0x96, 0xb4, 0x9c, 0x49, 0xb4, 0x51, 0x48, 0xa7 } };

//---------------------------------------------------------------------
// Unicode byte order mark
//---------------------------------------------------------------------
extern const WCHAR UnicodeByteOrderMark = 0xFEFF;

//---------------------------------------------------------------------
// dictionary table delimiter
//---------------------------------------------------------------------
extern const WCHAR KeywordDelimiter = L'=';
extern const WCHAR StringDelimiter  = L'\"';

//---------------------------------------------------------------------
// defined item in setting file table [PreservedKey] section
//---------------------------------------------------------------------
extern const WCHAR ImeModeDescription[] = L"Chinese/English input (Shift)";
extern const int ImeModeOnIcoIndex = IME_MODE_ON_ICON_INDEX;
extern const int ImeModeOffIcoIndex = IME_MODE_OFF_ICON_INDEX;

extern const WCHAR DoubleSingleByteDescription[] = L"Double/Single byte (Shift+Space)";
extern const int DoubleSingleByteOnIcoIndex = IME_DOUBLE_ON_INDEX;
extern const int DoubleSingleByteOffIcoIndex = IME_DOUBLE_OFF_INDEX;

extern const WCHAR PunctuationDescription[] = L"Chinese/English punctuation (Ctrl+.)";
extern const int PunctuationOnIcoIndex = IME_PUNCTUATION_ON_INDEX;
extern const int PunctuationOffIcoIndex = IME_PUNCTUATION_OFF_INDEX;

//---------------------------------------------------------------------
// defined item in setting file table [LanguageBar] section
//---------------------------------------------------------------------
extern const WCHAR LangbarImeModeDescription[] = L"Conversion mode";
extern const WCHAR LangbarDoubleSingleByteDescription[] = L"Character width";
extern const WCHAR LangbarPunctuationDescription[] = L"Punctuation";

//---------------------------------------------------------------------
// windows class / titile / atom
//---------------------------------------------------------------------
extern const WCHAR CandidateClassName[] = L"JiuyunIME.CandidateWindow";
ATOM AtomCandidateWindow;

extern const WCHAR ShadowClassName[] = L"JiuyunIME.ShadowWindow";
ATOM AtomShadowWindow;

extern const WCHAR ScrollBarClassName[] = L"JiuyunIME.ScrollBarWindow";
ATOM AtomScrollBarWindow;

BOOL RegisterWindowClass()
{
    if (!CBaseWindow::_InitWindowClass(CandidateClassName, &AtomCandidateWindow))
    {
        return FALSE;
    }
    if (!CBaseWindow::_InitWindowClass(ShadowClassName, &AtomShadowWindow))
    {
        return FALSE;
    }
    if (!CBaseWindow::_InitWindowClass(ScrollBarClassName, &AtomScrollBarWindow))
    {
        return FALSE;
    }
    return TRUE;
}

//---------------------------------------------------------------------
// defined full width characters for Double/Single byte conversion
//---------------------------------------------------------------------
extern const WCHAR FullWidthCharTable[] = {
    //         !       "       #       $       %       &       '       (    )       *       +       ,       -       .       /
    0x3000, 0xFF01, 0xFF02, 0xFF03, 0xFF04, 0xFF05, 0xFF06, 0xFF07, 0xFF08, 0xFF09, 0xFF0A, 0xFF0B, 0xFF0C, 0xFF0D, 0xFF0E, 0xFF0F,
    // 0       1       2       3       4       5       6       7       8       9       :       ;       <       =       >       ?
    0xFF10, 0xFF11, 0xFF12, 0xFF13, 0xFF14, 0xFF15, 0xFF16, 0xFF17, 0xFF18, 0xFF19, 0xFF1A, 0xFF1B, 0xFF1C, 0xFF1D, 0xFF1E, 0xFF1F,
    // @       A       B       C       D       E       F       G       H       I       J       K       L       M       N       0
    0xFF20, 0xFF21, 0xFF22, 0xFF23, 0xFF24, 0xFF25, 0xFF26, 0xFF27, 0xFF28, 0xFF29, 0xFF2A, 0xFF2B, 0xFF2C, 0xFF2D, 0xFF2E, 0xFF2F,
    // P       Q       R       S       T       U       V       W       X       Y       Z       [       \       ]       ^       _
    0xFF30, 0xFF31, 0xFF32, 0xFF33, 0xFF34, 0xFF35, 0xFF36, 0xFF37, 0xFF38, 0xFF39, 0xFF3A, 0xFF3B, 0xFF3C, 0xFF3D, 0xFF3E, 0xFF3F,
    // '       a       b       c       d       e       f       g       h       i       j       k       l       m       n       o       
    0xFF40, 0xFF41, 0xFF42, 0xFF43, 0xFF44, 0xFF45, 0xFF46, 0xFF47, 0xFF48, 0xFF49, 0xFF4A, 0xFF4B, 0xFF4C, 0xFF4D, 0xFF4E, 0xFF4F,
    // p       q       r       s       t       u       v       w       x       y       z       {       |       }       ~
    0xFF50, 0xFF51, 0xFF52, 0xFF53, 0xFF54, 0xFF55, 0xFF56, 0xFF57, 0xFF58, 0xFF59, 0xFF5A, 0xFF5B, 0xFF5C, 0xFF5D, 0xFF5E
};

//---------------------------------------------------------------------
// defined punctuation characters
//---------------------------------------------------------------------
extern const struct _PUNCTUATION PunctuationTable[14] = {
    {L'!',  0xFF01},
    {L'$',  0xFFE5},
    {L'&',  0x2014},
    {L'(',  0xFF08},
    {L')',  0xFF09},
    {L',',  0xFF0C},
    {L'.',  0x3002},
    {L':',  0xFF1A},
    {L';',  0xFF1B},
    {L'?',  0xFF1F},
    {L'@',  0x00B7},
    {L'\\', 0x3001},
    {L'^',  0x2026},
    {L'_',  0x2014}
};

//+---------------------------------------------------------------------------
//
// CheckModifiers
//
//----------------------------------------------------------------------------

#define TF_MOD_ALLALT     (TF_MOD_RALT | TF_MOD_LALT | TF_MOD_ALT)
#define TF_MOD_ALLCONTROL (TF_MOD_RCONTROL | TF_MOD_LCONTROL | TF_MOD_CONTROL)
#define TF_MOD_ALLSHIFT   (TF_MOD_RSHIFT | TF_MOD_LSHIFT | TF_MOD_SHIFT)
#define TF_MOD_RLALT      (TF_MOD_RALT | TF_MOD_LALT)
#define TF_MOD_RLCONTROL  (TF_MOD_RCONTROL | TF_MOD_LCONTROL)
#define TF_MOD_RLSHIFT    (TF_MOD_RSHIFT | TF_MOD_LSHIFT)

#define CheckMod(m0, m1, mod)        \
    if (m1 & TF_MOD_ ## mod ##)      \
{ \
    if (!(m0 & TF_MOD_ ## mod ##)) \
{      \
    return FALSE;   \
}      \
} \
    else       \
{ \
    if ((m1 ^ m0) & TF_MOD_RL ## mod ##)    \
{      \
    return FALSE;   \
}      \
} \



BOOL CheckModifiers(UINT modCurrent, UINT mod)
{
    mod &= ~TF_MOD_ON_KEYUP;

    if (mod & TF_MOD_IGNORE_ALL_MODIFIER)
    {
        return TRUE;
    }

    if (modCurrent == mod)
    {
        return TRUE;
    }

    if (modCurrent && !mod)
    {
        return FALSE;
    }

    CheckMod(modCurrent, mod, ALT);
    CheckMod(modCurrent, mod, SHIFT);
    CheckMod(modCurrent, mod, CONTROL);

    return TRUE;
}

//+---------------------------------------------------------------------------
//
// UpdateModifiers
//
//    wParam - virtual-key code
//    lParam - [0-15]  Repeat count
//  [16-23] Scan code
//  [24]    Extended key
//  [25-28] Reserved
//  [29]    Context code
//  [30]    Previous key state
//  [31]    Transition state
//----------------------------------------------------------------------------

USHORT ModifiersValue = 0;
BOOL   IsShiftKeyDownOnly = FALSE;
BOOL   IsControlKeyDownOnly = FALSE;
BOOL   IsAltKeyDownOnly = FALSE;

BOOL UpdateModifiers(WPARAM wParam, LPARAM lParam)
{
    // high-order bit : key down
    // low-order bit  : toggled
    SHORT sksMenu = GetKeyState(VK_MENU);
    SHORT sksCtrl = GetKeyState(VK_CONTROL);
    SHORT sksShft = GetKeyState(VK_SHIFT);

    switch (wParam & 0xff)
    {
    case VK_MENU:
        // is VK_MENU down?
        if (sksMenu & 0x8000)
        {
            // is extended key?
            if (lParam & 0x01000000)
            {
                ModifiersValue |= (TF_MOD_RALT | TF_MOD_ALT);
            }
            else
            {
                ModifiersValue |= (TF_MOD_LALT | TF_MOD_ALT);
            }

            // is previous key state up?
            if (!(lParam & 0x40000000))
            {
                // is VK_CONTROL and VK_SHIFT up?
                if (!(sksCtrl & 0x8000) && !(sksShft & 0x8000))
                {
                    IsAltKeyDownOnly = TRUE;
                }
                else
                {
                    IsShiftKeyDownOnly = FALSE;
                    IsControlKeyDownOnly = FALSE;
                    IsAltKeyDownOnly = FALSE;
                }
            }
        }
        break;

    case VK_CONTROL:
        // is VK_CONTROL down?
        if (sksCtrl & 0x8000)    
        {
            // is extended key?
            if (lParam & 0x01000000)
            {
                ModifiersValue |= (TF_MOD_RCONTROL | TF_MOD_CONTROL);
            }
            else
            {
                ModifiersValue |= (TF_MOD_LCONTROL | TF_MOD_CONTROL);
            }

            // is previous key state up?
            if (!(lParam & 0x40000000))
            {
                // is VK_SHIFT and VK_MENU up?
                if (!(sksShft & 0x8000) && !(sksMenu & 0x8000))
                {
                    IsControlKeyDownOnly = TRUE;
                }
                else
                {
                    IsShiftKeyDownOnly = FALSE;
                    IsControlKeyDownOnly = FALSE;
                    IsAltKeyDownOnly = FALSE;
                }
            }
        }
        break;

    case VK_SHIFT:
        // is VK_SHIFT down?
        if (sksShft & 0x8000)    
        {
            // is scan code 0x36(right shift)?
            if (((lParam >> 16) & 0x00ff) == 0x36)
            {
                ModifiersValue |= (TF_MOD_RSHIFT | TF_MOD_SHIFT);
            }
            else
            {
                ModifiersValue |= (TF_MOD_LSHIFT | TF_MOD_SHIFT);
            }

            // is previous key state up?
            if (!(lParam & 0x40000000))
            {
                // is VK_MENU and VK_CONTROL up?
                if (!(sksMenu & 0x8000) && !(sksCtrl & 0x8000))
                {
                    IsShiftKeyDownOnly = TRUE;
                }
                else
                {
                    IsShiftKeyDownOnly = FALSE;
                    IsControlKeyDownOnly = FALSE;
                    IsAltKeyDownOnly = FALSE;
                }
            }
        }
        break;

    default:
        IsShiftKeyDownOnly = FALSE;
        IsControlKeyDownOnly = FALSE;
        IsAltKeyDownOnly = FALSE;
        break;
    }

    if (!(sksMenu & 0x8000))
    {
        ModifiersValue &= ~TF_MOD_ALLALT;
    }
    if (!(sksCtrl & 0x8000))
    {
        ModifiersValue &= ~TF_MOD_ALLCONTROL;
    }
    if (!(sksShft & 0x8000))
    {
        ModifiersValue &= ~TF_MOD_ALLSHIFT;
    }

    return TRUE;
}

//---------------------------------------------------------------------
// override CompareElements
//---------------------------------------------------------------------
BOOL CompareElements(LCID locale, const CStringRange* pElement1, const CStringRange* pElement2)
{
    return (CStringRange::Compare(locale, (CStringRange*)pElement1, (CStringRange*)pElement2) == CSTR_EQUAL) ? TRUE : FALSE;
}
}