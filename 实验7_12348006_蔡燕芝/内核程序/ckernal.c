extern void myprintf(char *mess);
extern int getline(char *mess);
extern void cls();
extern int runProg(int numOfSectors, int startOfSectors);/*创建进程参数为程序的扇区数和其实扇区编码*/
extern void getDate(int *yy, int *mm, int *dd);/*c参数为年，月，日的参数的地址*/
extern void getTime(int *hh, int *mm, int *ss);/*参数为时分秒的地址*/
/*extern void powerOff();*/
extern void setMyClock();
extern void setTimer();
extern int isUserMode;
/*数据模块*/
int disp_pos = 0;
char tmp[100] = {'\0'}; /*键入的信息存放的地方*/
int n = 0;    /*获取的字符串的个数*/
char message[150] = "Welcom to MyOS v2.1 copyright (c) YZ Cai Time: 2014\\5\\13 \r\nType \"help\" for more infomations about commands\r\n";
char helpInfo[250] = "type \"help\" for help\r\ntype \"time\" to get current time\r\ntype \"date\" to get current date\r\ntype \"run\" to choose user programs to run\r\ntype \"asc\" to show the ascii code number of char\r\ntype \"exit()\" to let OS off\r\n";
char ch;

void showNum(int BCDnum){ 
	/*显示BCD编码的数字*/
	int n1 = 16*16*16;
	int n2 = 0;
	char tmpNum[6] = {'\0'};
	int index = 0;
	if(BCDnum == 0)
	{
		myprintf("00");
		return;
	}
	while(BCDnum < n1)
		n1/=16;
	while(n1 > 0)
	{
		n2 = BCDnum/n1;
		tmpNum[index] = n2 + '0';
		index++;
		BCDnum %= n1;
		n1/=16;
	}
	tmpNum[index] = '\0';
	myprintf(tmpNum);
}

void  showDate(){
	int yy = 0;
	int mm = 0;
	int dd = 0;
	getDate(&yy, &mm, &dd);/*获取时间*/

	/*显示获取的年月日*/
	showNum(yy);
	printchar('-');
	showNum(mm);
	printchar('-');
	showNum(dd);
}

void showTime(){
	int hh = 0;
	int mm = 0;
	int ss = 0;
	getTime(&hh, &mm, &ss); 

	/*显示获取的时分秒*/
	showNum(hh);
	printchar(':');
	showNum(mm);
	printchar(':');
	showNum(ss);
}

void run(int a, int b)
{
	if(!runProg(a,b))
		myprintf("create process failed!\r\n");
}


void showAscii(char ch){
	/*显示字符的asc码并输出结果*/
	int num = ch;
	char tmpNum[5] = {'\0'};
	int index = 0;
	int n1 = num, n2 = 100;
	while(n2 != 0)
	{

		n1 = num / n2;
		tmpNum[index] = n1 + '0';
		index++;
		num = num % n2;
		n2/=10;
	}
	tmpNum[index] = '\0';
	myprintf(tmpNum);
}

void toInput()
{
	myprintf(">> ");
}

void userInput()
{
	/*进入run分支时的显示*/
	myprintf("user>> ");
}

void ascInput()
{
	/*进入asc分支时的显示*/
	myprintf("asc>> ");
}

void toNextLine(){
	/*换行*/
	myprintf("\r\n");
}

int i = 0;

int mystrcmp(char str1[], char str2[], int n1, int n2)
{
	/*对比输入的命令str1是否如何和str2要求的相同*/
	if(n1 < n2)
	{
		return 0;
	}	
	for(i = 0; i < n2; i++)
	{
		if(str1[i] != str2[i])
		{
			return 0;
		}
	}
	return 1;
}

void cmain(){
	cls(); /*清屏*/
	setTimer();
	myprintf(message);
	toNextLine();
	while(1){
		toInput();
		n = 0;
		n = getline(tmp);
		toNextLine();

		if(mystrcmp(tmp,"help",n,4) == 1) /*进入help分支*/
		{
			myprintf(helpInfo);
		}
	
		else if(mystrcmp(tmp,"time",n,4) == 1)/*进入time分支*/
		{
			myprintf("Current time is : ");
			showTime();
		}
		else if(mystrcmp(tmp,"date",n,4) == 1)/*进入date分支*/
		{
			myprintf("Current date is : ");
			showDate();
		}
		else if(mystrcmp(tmp,"asc",n,3) == 1)/*进入asc分支*/
		{
			myprintf("please type the char which you want to show the ascii code number(with one input, type \"exit()\" to quit)\r\n");
			toNextLine();
			while(1)
			{
				ascInput();
				n = getline(tmp);
				toNextLine();
				if(mystrcmp(tmp,"exit()",n,6) == 1)
				{
					break;
				}
				else if(n != 1)
				{
					myprintf("your input couldn't be recognized,please try again.");
				}
				else
				{
					ch = tmp[0];
					printchar(ch);
					myprintf(" 's ascii code number is : ");
					showAscii(ch);
				}
				toNextLine();
				toNextLine();
			}
		}
		else if(mystrcmp(tmp,"run",n,3) == 1)/*进入run分支*/
		{

			myprintf("here are four four programs in MyOS,numbered with a, b, c, d\r\n");
			myprintf("\r\nplease input \"run a\" or \"run b\" to run one program, input \"run acb\" to run a, c, b in order(type \"exit()\" to quit)\r\n");
			toNextLine();
			while(1)
			{
				userInput();
				n = getline(tmp);
				toNextLine();
				
				if(mystrcmp(tmp,"exit()",n,6) == 1)
				{
					break;
				}
				else if(mystrcmp(tmp, "run ",n,4) == 1)
				{
					int isQuit = 0;
					for(i = 4; i < n; i++)
						if((tmp[i] < 'a' || tmp[i] > 'd') && tmp[i] != ' ') /*判断要执行的程序是否符合要求*/
						{
							myprintf("your input couldn't be recognized,please try again.");
							isQuit = 1;
							break;
						}

					if(isQuit == 0)/*键入合理时，按要求的顺序执行子程序*/
                    {
                    	for(i = 4; i < n; i++)
						{
							switch(tmp[i])
							{
								case 'a':
									run(2, 12);
									break;
								case 'b':
									run(2, 14);
									break;
								case 'c':
									run(2, 16);
									break;
								case 'd':
									run(2, 18);
									break;
								case ' ':
									break;
							}
						}
						setMyClock();
						while(isUserMode)
								;
					}
				}
				else{
					myprintf("your input couldn't be recognized,please try again.");
				}
				toNextLine();
				toNextLine();
			}
		}/*
		else if(mystrcmp(tmp,"exit()",n,6) == 1)/*关机*/
		/*{
			powerOff();
		}*/
		else
		{
			myprintf("your input couldn't be recognized,please try again.");
		}
		toNextLine();
		toNextLine();
	}
}
