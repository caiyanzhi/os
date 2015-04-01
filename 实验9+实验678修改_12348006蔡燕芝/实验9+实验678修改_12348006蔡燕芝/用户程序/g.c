char b[50];
int in;/*放入字符的位置*/
int out;/*读出字符的位置*/
char ch_in;/*生产的字符*/
char ch_out[2]=" ";
int s1,s2,n;
int rest_in;
int rest_out;
int is_full;/*缓冲区是否满了*/
char tmpMess[10];
extern void myprintf(char *mess);

void init()
{
	in = 0;
	out = 0;
	ch_in = 'A' - 1;
	rest_out = rest_in = 260;
	is_full  = 0;
}

void produce()
{
	ch_in++;
	if(ch_in >'Z')
	{
			ch_in = 'A';
	}
}
void producer()
{
	while(1){
		produce();
		p(s2);
		b[in] = ch_in;
		in++;		
		if(in >= 50) /*循环放入缓冲区*/
			in = 0;
		rest_in--;
		if(in == out) /*缓冲区满*/
		{
			is_full = 1;
		}
		V(s2);
		V(n);

		if(is_full)  /*缓冲区满，阻塞生产者*/
		{
			p(s1);
			is_full = 0;
		}

		if(rest_in == 0)
		{
			myprintf("produce finish\r\n");
			break;
		}
	}
}

void consume()
{
	myprintf(ch_out);
	if(ch_out[0]=='Z')
		myprintf("\r\n");
}

void consumer()
{
	int tmp;
	while(1)
	{
			P(n);
			p(s2);
			ch_out[0] = b[out];
			consume();
			if(is_full == 1 && in == out) /*缓冲区满 ---即将变为----> 不满*/
			{
				V(s1);
			}
			out++;
			if(out>=50)  /*循环从缓冲区读取*/
				out = 0;
		
			rest_out--;
			tmp = rest_out;
		    V(s2);

			if(tmp <= 1)/*由于有两个消费者*/
			{
				myprintf("consume finish\r\n");
				break;
			}
	}
}

void cmain()
{
	int pid;
	
	s1 = SemaGet(0);
	s2 = SemaGet(1);
	n = SemaGet(0);

	if(s2 < 0 || n < 0 || s1 < 0)
	{
		myprintf("get Semaphore failed\r\n");
		exit(-1);
	}


	init();
	pid = fork();/*创建第1个消费者*/
	if(pid > 0)
		pid = fork();/*创建第2个消费者*/
	if(pid == 0)
	{
		myprintf("begin consume\r\n");
		consumer();
		
	}
	else if(pid > 0)
	{
		myprintf("begin produce\r\n");
		producer();
	}
	else
	{
		myprintf("create sub prog failed!\r\n");
		SemaFree(s1);
		SemaFree(s2);
		SemaFree(n);
		exit(-1);
	}
	SemaFree(s1);
	SemaFree(s2);
	SemaFree(n);
	exit(0);
}
