using System;
using System.Windows.Data;

namespace C10LP_App.Converter
{
    public class IsConnectedSymbolConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            return (string)((bool)value? "&#xE703;" : "&#xE71A;");
        }

        public object ConvertBack(object value, Type targetType, object parameter, System.Globalization.CultureInfo culture)
        {
            return Binding.DoNothing;
        }
    }
}
