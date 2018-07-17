using System;
using System.Runtime.InteropServices;

namespace C10LP_App.Model
{
    [StructLayout(LayoutKind.Explicit, Pack = 1)]
    struct LedData
    {
        [MarshalAs(UnmanagedType.U4)]
        [FieldOffset(0)]
        public UInt32 addr;

        [MarshalAs(UnmanagedType.U4)]
        [FieldOffset(4)]
        public UInt32 color; // RGBW (0...31)
    }
}
