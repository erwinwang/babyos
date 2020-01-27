void test();
void test()
{
     unsigned long base = 0xb8000;
     base += 4;
     *(char*)base = 'W';
    base++;
    *(char*)base = 0xfc;
}