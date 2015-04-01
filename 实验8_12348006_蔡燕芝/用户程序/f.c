char words[100] = "";
char zhufu[60] = "Father will live one year after anther for ever!";
char tmpMess[10] = "";
extern void myprintf(char* Mess);
extern void myInt2Chars(int num, char *pChars);
extern  char myGetChar();
extern void SemaFree(int s);
extern int SemaGet(int value); 
char ch;
int zhufu_crt = 0;
int max_read = 100;

/*清空字符串*/
void clearWords()
{
	int i = 0;
	
	while(words[i])
	{
		words[i]='\0';
		i++;
	}
}

/*判断是否祝福*/
void isZhuFu()
{
	int i = 0;
	int k = 1;
	while(zhufu[i])
	{
		if(zhufu[i] != words[i])
		{
			k = 0;
			break;
		}
		i++;
	}
	if(k)
		zhufu_crt++;
}

 /*复制字符串str1 = str2*/
void strcopy(char *str1, char *str2,int pid)
{
	int i = 0;
	while(str2[i])
	{
		str1[i]=str2[i];
		i++;
	}

	str1[i] = '\0';
}

void cmain()
{
	int s;
	int pid;
	int tmp;
	s = SemaGet(1);
	if(s < 0)
	{
		myprintf("get Semaphore failed\r\n");
		exit(-1);
	}
	myInt2Chars(s,tmpMess);
	myprintf("get Semaphore = ");
	myprintf(tmpMess);
	myprintf("\r\n");
	clearWords();
	pid = fork();
	if(pid > 0)
	{
		pid = fork();
	}
	if(pid == 0)
	{
		while(1)
		{
			clearWords(); /*清空CS缓冲区*/
			strcopy(words,zhufu,pid);/*写CS缓冲区*/
			tmp = max_read;/*max_read用于判断是否结束*/
			if(max_read <= 0)
			{
				myprintf("son stop sending zhufu\r\n");
				break;
			}
		}
	}
	else if(pid == -1)
	{
		myprintf("create sub prog failed!\r\n");
		exit(-1);
	}
	else
	{
		while(1)
		{
			if(words[0]) /*若缓冲区有内容*/
			{
				max_read--;/*max_read用于判断是否结束*/
				myprintf("receive zhufu: ");
				myprintf(words);/*读CS缓冲区*/

				myprintf("\r\n");
				isZhuFu();/*判断CS缓冲区区是否是祝福*/
			}
			else
				;

			if(max_read <= 0)
			{
				SemaFree(s);
				myprintf("father quit\r\nrecveive zhufu count = ");
				myInt2Chars(zhufu_crt,tmpMess);
				myprintf(tmpMess);
				myprintf("\r\n");
				break;
			}
		}
	}

	exit(0);
}