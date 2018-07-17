using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media;

namespace C10LP_App.Model
{
    public static class ColorGen
    {
        public static byte[] GenWS2812(Color[] cc)
        {
            UInt32 count = 0;
            if (cc.Length > 0)
            {
                byte[] data = new byte[cc.Length * 4 * 2];

                foreach (Color c in cc)
                {
                    byte r = (byte)(c.R * c.ScA);
                    byte g = (byte)(c.G * c.ScA);
                    byte b = (byte)(c.B * c.ScA);
                    LedData led = new LedData() { addr = count, color = (UInt32)(r + (g << 8) + (b << 16)) };
                    byte[] data_b = getBytes(led);
                    data_b.CopyTo(data, count * 4 * 2);
                    count++;
                }

                return data;
            }
            return null;
        }

        public static byte[] GenSK6812RGBW(Color[] cc, byte[] ww)
        {
            UInt32 count = 0;
            if (cc.Length > 0)
            {
                byte[] data = new byte[cc.Length * 4 * 2];

                foreach (Color c in cc)
                {
                    byte r = (byte)(c.R * c.ScA);
                    byte g = (byte)(c.G * c.ScA);
                    byte b = (byte)(c.B * c.ScA);
                    byte w = ww[count];
                    LedData led = new LedData() { addr = count + 0x8000_0000, color = (UInt32)(r + (g << 8) + (b << 16) + (w << 24)) };
                    byte[] data_b = getBytes(led);
                    data_b.CopyTo(data, count * 4 * 2);
                    count++;
                }

                return data;
            }
            return null;
        }

        static byte[] getBytes(LedData str)
        {
            int size = Marshal.SizeOf(str);
            byte[] arr = new byte[size];

            IntPtr ptr = Marshal.AllocHGlobal(size);
            Marshal.StructureToPtr(str, ptr, true);
            Marshal.Copy(ptr, arr, 0, size);
            Marshal.FreeHGlobal(ptr);
            return arr;
        }
    }
}
