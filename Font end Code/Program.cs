// See https://aka.ms/new-console-template for more information
using System;
namespace Bai1
{
    class Program
    {
        static void Main(string[] arg)
        {  
            int a,b;
            int kq=0;
            int c;
            Console.WriteLine("Nhap so: ");
            a=int.Parse(Console.ReadLine());
            b=int.Parse(Console.ReadLine()); 
            TBP1(ref a , ref b);
            TBP(a,b,ref kq);
            c= TBP2(ref a,ref b);
            Console.WriteLine("Tong binh phuong a va b la: {0}",c);
        }
        static void TBP1( ref int a, ref int b)
        {
            Console.WriteLine("Tong binh phuong a va b la: {0}", (a*a+b*b));
        }
        static void TBP (int a,int b, ref int kq)
        {
            kq = a*a+b*b;
            Console.WriteLine("Tong binh phuong a va b la: {0}",kq);
        }
        static int TBP2(ref int a, ref int b)
        {
            int S=0;
            S=a*a+b*b;
            return S;
        }
    }
}
