extern void myprintf(char *mess);
extern void exit(int a);
extern void myInt2Chars(int num, char *pChars);
extern int fork();
extern void wait();
char str[100] = "hello i love os!! But can you show me no mistakes? T^T";
int strSize;
char tempMess[100];
int countStr(char *mess)
{
	int size = 0;
	while(mess[size])
	{
		size++;
	}
	return size;
}

void cmain()
{
	int pid;
	myprintf("test fork!!");

/*
 1）在父进程中，fork返回新创建子进程的进程ID;
 2）在子进程中，fork返回0;
 3）如果出现错误，fork返回一个负值;
*/
	pid = fork();         
	if(pid == 0)
	{
		myprintf("hello!! I am the child.\r\n");
		strSize = countStr(str);

		/*进程退出*/
		exit(0);
	}
	else if(pid == -1)
	{
		myprintf("create child failed！\r\n");
		exit(-1);
	}
	else
	{
		myprintf("hello!! I am the father of prog ");
		myInt2Chars(pid,tempMess);
		myprintf(tempMess);
		myprintf(".\r\n");
		myprintf("ready to wait.\r\n");
		/*进程等待*/
		wait();
		myprintf("wait end!\r\n");
		myprintf("Result: the size of string is ");
		myInt2Chars(strSize, tempMess);
		myprintf(tempMess);
		myprintf(".\r\n");
		exit(0);
	}
}