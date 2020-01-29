void test();
static unsigned long base = 0xb8000;
void test()
{
    base+=4;
    *(char*)base = 'W';
    base++;
    *(char*)base = 0xfc;
    base++;
}