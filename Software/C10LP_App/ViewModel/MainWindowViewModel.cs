using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO.Ports;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using C10LP_App.Model;
using Prism.Mvvm;

namespace C10LP_App.ViewModel
{
    class MainWindowViewModel : BindableBase
    {
        SerialPort sp = new SerialPort();

        #region Публичные свойства

        #region IsConnected
        bool _IsConnected;
        public bool IsConnected
        {
            get { return _IsConnected; }
            set { SetProperty<bool>(ref _IsConnected, value);  }
        }
        #endregion

        #region AvailiblePorts
        string[] _AvailiblePorts;
        public string[] AvailiblePorts
        {
            get { return _AvailiblePorts; }
            private set { SetProperty<string[]>(ref _AvailiblePorts, value); }
        }
        #endregion

        public string PortName { get; set; } = "";
        public string PortBaudrate { get; set; } = "115200";
        public string PortDatabits { get; set; } = "8";
        public Parity PortParity { get; set; } = Parity.None;
        public StopBits PortStopbits { get; set; } = StopBits.One;
        public Handshake PortHandshaking { get; set; } = Handshake.None;
        #endregion

        #region Публичные свойства - WS2812

        Color _WS2812_1, _WS2812_2, _WS2812_3;
        public Color WS2812_1
        {
            get { return _WS2812_1; }
            set
            {
                if (SetProperty<Color>(ref _WS2812_1, value))
                {
                    SendWS2812();
                }
            }
        }

        public Color WS2812_2
        {
            get { return _WS2812_2; }
            set
            {
                if (SetProperty<Color>(ref _WS2812_2, value))
                {
                    SendWS2812();
                }
            }
        }

        public Color WS2812_3
        {
            get { return _WS2812_3; }
            set
            {
                if (SetProperty<Color>(ref _WS2812_3, value))
                {
                    SendWS2812();
                }
            }
        }
        #endregion

        #region Публичные свойства - SK6812RGBW

        Color _SK6812RGBW_1, _SK6812RGBW_2, _SK6812RGBW_3;
        byte _SK6812RGBW_W_1, _SK6812RGBW_W_2, _SK6812RGBW_W_3;

        #region SK6812RGBW_*
        public Color SK6812RGBW_1
        {
            get { return _SK6812RGBW_1; }
            set
            {
                if (SetProperty<Color>(ref _SK6812RGBW_1, value))
                {
                    SendSK6812RGBW();
                }
            }
        }

        public Color SK6812RGBW_2
        {
            get { return _SK6812RGBW_2; }
            set
            {
                if (SetProperty<Color>(ref _SK6812RGBW_2, value))
                {
                    SendSK6812RGBW();
                }
            }
        }

        public Color SK6812RGBW_3
        {
            get { return _SK6812RGBW_3; }
            set
            {
                if (SetProperty<Color>(ref _SK6812RGBW_3, value))
                {
                    SendSK6812RGBW();
                }
            }
        }
        #endregion

        #region SK6812RGBW_W_*
        public byte SK6812RGBW_W_1
        {
            get { return _SK6812RGBW_W_1; }
            set
            {
                if (SetProperty<byte>(ref _SK6812RGBW_W_1, value))
                {
                    SendSK6812RGBW();
                }
            }
        }

        public byte SK6812RGBW_W_2
        {
            get { return _SK6812RGBW_W_2; }
            set
            {
                if (SetProperty<byte>(ref _SK6812RGBW_W_2, value))
                {
                    SendSK6812RGBW();
                }
            }
        }

        public byte SK6812RGBW_W_3
        {
            get { return _SK6812RGBW_W_3; }
            set
            {
                if (SetProperty<byte>(ref _SK6812RGBW_W_3, value))
                {
                    SendSK6812RGBW();
                }
            }
        }
        #endregion

        #endregion

        #region Команды
        public ICommand С_Connect { get; set; }
        public ICommand С_Update { get; set; }
        public ICommand C_OpenWebUri { get; set; } = new RelayCommand((p) =>
        {
            Uri nu = p as Uri;
            if (nu != null)
                Process.Start(new ProcessStartInfo(nu.AbsoluteUri));
        });
        #endregion

        #region Конструктор
        public MainWindowViewModel()
        {
            UpdateAvailiblePorts();

            WS2812_1 = WS2812_2 = WS2812_3 = Colors.Black;
            SK6812RGBW_1 = SK6812RGBW_2 = SK6812RGBW_3 = Colors.Black;

            #region Команды
            С_Connect = new RelayCommand((p) =>
            {
                if(IsConnected)
                {
                    SerialPort_Disconnect();
                }
                else
                {
                    SerialPort_Connect();
                }
            }, (p) => !String.IsNullOrEmpty(PortName));

            С_Update = new RelayCommand((p) =>
            {
                UpdateAvailiblePorts();
            }, (p)=> !IsConnected);
            #endregion
        }
        #endregion

        #region Приватные методы
        void UpdateAvailiblePorts()
        {
            AvailiblePorts = SerialPort.GetPortNames();

            if (AvailiblePorts.Length > 0)
                PortName = AvailiblePorts[0];
        }

        void SendWS2812()
        {
            if(IsConnected)
            {
                byte[] data = ColorGen.GenWS2812(new Color[] { WS2812_1, WS2812_2, WS2812_3 });
                if(data != null)
                    sp.Write(data, 0, data.Length);
            }
        }

        void SendSK6812RGBW()
        {
            if (IsConnected)
            {
                byte[] data = ColorGen.GenSK6812RGBW(new Color[] { SK6812RGBW_1, SK6812RGBW_2, SK6812RGBW_3 }, new byte[] { SK6812RGBW_W_1, SK6812RGBW_W_2, SK6812RGBW_W_3 });
                if (data != null)
                    sp.Write(data, 0, data.Length);
            }
        }

        void SerialPort_Connect()
        {
            sp.PortName = PortName;
            sp.BaudRate = int.Parse(PortBaudrate.Replace("System.Windows.Controls.ComboBoxItem: ", "")); // пока так сойдет...
            sp.DataBits = int.Parse(PortDatabits.Replace("System.Windows.Controls.ComboBoxItem: ", ""));
            if (PortStopbits != StopBits.None) // какой-то прикол... не поддерживается, но оставим в enum
                sp.StopBits = PortStopbits;
            else
                sp.StopBits = StopBits.One;

            sp.Handshake = PortHandshaking;
            //sp.DataReceived += SerialPort_DataReceived;

            try
            {
                sp.Open();
                IsConnected = sp.IsOpen;
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка!");
            }
        }

        void SerialPort_Disconnect()
        {
            sp.Close();
            IsConnected = false;
        }
        #endregion
    }
}
