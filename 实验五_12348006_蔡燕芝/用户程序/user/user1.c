extern void myShowOuch();
extern void myUpper(char *pChars);
extern void myLowwer(char *pChars);
extern int myChars2Int(char *pChars);
extern void myInt2Chars(int num, char *pChars);
extern void myPrintCharsInPosition(int row,int col, char *pChars);
extern char myGetChar();
extern int myGetChars(char  *pChars);
extern void myShowTime();
extern void myprintf(char *pChars);
char Mess[100];
	char Message[100] = "abcde";
	char numMessage[100] = "1234";
	int num = 1234;
	char chch;
void main()
{
	myprintf("This program is to test int33 server. Please input the function num: 1-9 to test the server.such as input 1 to test function 1\r\n");
	
	while(1){
		myprintf(">> ");
		myGetChars(Mess);
		myprintf("\r\n");
		switch (Mess[0])
		{
			case '0':
				myprintf("it is to show Ouch in the center of the screen\r\n");
				myShowOuch();
				myprintf("\r\n");
				break;
			case '1':
				myprintf("it is to upper 'abcde' into Upper char\r\n");
				myUpper(Message);
				myprintf(Message);
				myprintf("\r\n");
				break;
			case '2':
				myprintf("it is to lowwer 'abcde' into Upper char\r\n");
				myLowwer(Message);
				myprintf(Message);
				myprintf("\r\n");
				break;
			case '3':
				myprintf("it is to change '1234' to number 1234\r\n");
				num = myChars2Int(numMessage);
				myprintf("\r\ninput 4 will see the result\n\r");
				break;
			case '4':
				myprintf("it is to change 1234 to '1234'\r\n");
				myInt2Chars(num,numMessage);
				myprintf(numMessage);
				myprintf("\r\n");
				break;
			case '5':
				myprintf("to put 'abcde' in (13, 38)\r\n");
				myPrintCharsInPosition(13,38, Message);
				myprintf("\r\n");
				break;
			case '6':
				myprintf("At the beginning of this program, this function has been tested\r\n");
				break;
			case '7': 
				myprintf("At the beginning of this program, this function has been tested\r\n");
				break;
			case '8':
				myprintf("it is to show current time in the button of the screen\r\n");
				myShowTime();
				myprintf("\r\n");
				break;	
			case '9':
				myprintf("every output of this program is the test 9\r\n");
				break;
			default:
				break;
		}
	}
}