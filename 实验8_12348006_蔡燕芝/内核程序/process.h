/*Kernel.h*/
/*内核数据结构类型和数据结构*/
/*create by 蔡燕芝*/
/*last edited time : 2014年5月19日21:18:31*/
#define MAX_NrPCB 50
int CurrentPCBno = 0; /*当前进程号*/
int isUserMode = 0; /*判断是否处于用户态*/
int processNum = 0; /*进程计数*/
int baseSeg = 0x2000; /*每个进程的段地址 = baseSeg + SegLength*pid */
int SegLength = 0x200;   /*每一段的段地址长度*/
int currentSeg;
int SP_OFF = 0x100; 	 /*段地址偏移量*/
int SS_baseSeg = 0xE000;
int SS_Len = 0x100;

int STACK_LIST[MAX_NrPCB];/*SS = SS_BaseSeg + index * SS_LEN; SP = 100-4; 等于0代表该栈区可用*/
int fpid;
int pid;
/*#define Debug*/
extern void myprintf(char *mess);
extern void memcopy(int ss1,int ss2, int length); /*a = b*/
/*数值num变成对应的数字字符串存储在Message中*/
extern void int2Chars(char* Message, int num);
char tmpMessage[10] = "love you";

typedef enum PCB_Status{READY=0,GO = 1,EXIT,RUNNING, BLOCKED,SUSPENDED}PCB_Status;

typedef struct RegisterImage{
	int SS;
	int GS;
	int FS;
	int ES;
	int DS;
	int DI;
	int SI;
	int BP;
	int SP;
	int BX;
	int DX;
	int CX;
	int AX;
	int IP;
	int CS;
	int Flags;
}RegisterImage;

typedef struct PCB{
	RegisterImage regImg;/***registers will be saved in this struct automactically by timer interrupt***/
	/******/
	PCB_Status status;
	int used;/*进程控制块是否被使用*/
	int fpid;/*父进程id*/
	int pid;/*进程id*/
	int next;/*队列中下一个进程的pcb_id*/
}PCB;

/*进程表定义*/
PCB pcb_list[MAX_NrPCB];

/*获取当前进程表的地址*/
PCB* getCurrentPCB(){
	return &pcb_list[CurrentPCBno];
}

/*保存当前pcb*/
void SaveCurrentPCB(int ax,int cx, int dx, int bx, int sp, int bp, int si, int di, int ds ,int es,int fs,int gs, int ss,int call_save,int ip, int cs,int fl)
{
	pcb_list[CurrentPCBno].regImg.AX = ax;
	pcb_list[CurrentPCBno].regImg.BX = bx;
	pcb_list[CurrentPCBno].regImg.CX = cx;
	pcb_list[CurrentPCBno].regImg.DX = dx;

	pcb_list[CurrentPCBno].regImg.DS = ds;
	pcb_list[CurrentPCBno].regImg.ES = es;
	pcb_list[CurrentPCBno].regImg.FS = fs;
	pcb_list[CurrentPCBno].regImg.GS = gs;
	pcb_list[CurrentPCBno].regImg.SS = ss;

	pcb_list[CurrentPCBno].regImg.IP = ip;
	pcb_list[CurrentPCBno].regImg.CS = cs;
	pcb_list[CurrentPCBno].regImg.Flags = fl;
	
	pcb_list[CurrentPCBno].regImg.DI = di;
	pcb_list[CurrentPCBno].regImg.SI = si;
	pcb_list[CurrentPCBno].regImg.SP = sp + 18; /*恢复栈顶*/
	pcb_list[CurrentPCBno].regImg.BP = bp;
}

void Schedule(){
	if(isUserMode == 0) /*若非用户态即进程调度完毕，则返回内核*/
	{
		CurrentPCBno = 0;
		pcb_list[CurrentPCBno].status = RUNNING;
		return;
	}
	if(CurrentPCBno == 0)
	{
		pcb_list[CurrentPCBno].status = READY;  /*若是刚从内核进入，让其处于ready*/
	}

	if(pcb_list[CurrentPCBno].status == RUNNING)
		pcb_list[CurrentPCBno].status = READY;


	while(1)             /*调度算法：顺序轮转*/
	{
		CurrentPCBno = CurrentPCBno + 1;
		if(CurrentPCBno > MAX_NrPCB)
			CurrentPCBno = 1;

		if( pcb_list[CurrentPCBno].status == GO)
		{
			break;
		}
		if(pcb_list[CurrentPCBno].used == 1 && pcb_list[CurrentPCBno].status == READY){
			/*int2Chars(tmpMessage,pcb_list[CurrentPCBno].pid);*/
			pcb_list[CurrentPCBno].status = RUNNING;
			
			break;
		}
	}
	return;
}

/*初始化pcb*/
void initPCB(PCB *pcb, int id, int seg, int off)
{
	pcb->pid = id;
	pcb->fpid = -1; /*表示无父进程*/
	pcb->used = 1;
	pcb->next = 0;
	pcb->status = GO;
	pcb->regImg.GS = 0xb800;
	pcb->regImg.CS = seg;
	pcb->regImg.SS = seg;
	pcb->regImg.ES = seg;
	pcb->regImg.DS = seg;
	pcb->regImg.FS = seg;
	pcb->regImg.IP = off;
	pcb->regImg.DI = 0;
	pcb->regImg.SI = 0;
	pcb->regImg.BP = 0;
	pcb->regImg.SP = off - 4;
	pcb->regImg.BX = 0;
	pcb->regImg.AX = 0;
	pcb->regImg.CX = 0;
	pcb->regImg.DX = 0;
	pcb->regImg.Flags = 512;
}

/*运行新程序*/
int runProg(int numOfSectors, int startOfSectors)
{
	int x,y,z;
	int pid = createProcess();
	x = startOfSectors;
	y = x / 18;
	z = x % 18 + 1;
	LoadsubProgram(numOfSectors, y & 1, y >> 1, z);   /*加载进程到内存*/
	return pid;
}

/*创建新的进程*/
int createProcess()
{
	int i;
	for(i = 1; i < MAX_NrPCB; i++)
	{
		if(pcb_list[i].used == 0)
		{
			currentSeg = SegLength*(i-1) + baseSeg;
			initPCB( &pcb_list[i] ,i, currentSeg, SP_OFF); /*初始化pcb块*/
			processNum++;
			isUserMode = 1;
			return i;  /*创建进程成功*/
		}
	}
	return 0;  /*创建进程失败*/
}

/*wait阻塞自己*/
void wait()
{
	pcb_list[CurrentPCBno].status = BLOCKED;
	Schedule();
}

/*退出*/
void exit(int ch)
{
	PCB_Status state;
	int stack_id;
	fpid = pcb_list[CurrentPCBno].fpid;
	pcb_list[CurrentPCBno].status = EXIT;
	pcb_list[CurrentPCBno].used = 0;
	
	if( fpid != -1)
	{
		pcb_list[fpid].status = READY;
		pcb_list[fpid].regImg.AX = ch; /*记录退出信息*/
		stack_id = (pcb_list[CurrentPCBno].regImg.SS - SS_baseSeg)/SP_OFF;
		STACK_LIST[stack_id] = 0;
	}

	processNum--;
	if(processNum == 0)
	{
		isUserMode = 0;
	}
}


/*分配栈段，返回可用栈段编号*/
int requrireStackMemory()
{
	int i;
	for(i = 0; i < MAX_NrPCB; i++)
		if(STACK_LIST[i] == 0)
		{
			STACK_LIST[i] = 1;
			return i;
		}

	return -1;/*分配失败*/
}

/*
 1）在父进程中，fork返回新创建子进程的进程ID;
 2）在子进程中，fork返回0;
 3）如果出现错误，fork返回一个负值;
*/
int fork() /*-1表示分配子程序空间失败， -2表示分配栈空间失败 */
{
	int stack_id;
	pid = createProcess();

	if(pid)
	{
		/*申请 分配栈内存空间*/
		stack_id = requrireStackMemory();
		if(stack_id == -1)
		{
			/*分配栈空间失败，释放子程序空间*/
			pcb_list[pid].used = 0;
			pcb_list[CurrentPCBno].regImg.AX = -2; 
		}
		else	
		{
			pcb_list[pid] = pcb_list[CurrentPCBno]; /*复制父进程的状态信息*/
			pcb_list[pid].fpid = CurrentPCBno;      /*fpid = CurrentPCBno*/
			
			pcb_list[pid].regImg.SS = SS_baseSeg + stack_id * SS_Len;  /*重新分配栈段*/

			pcb_list[pid].regImg.SP = pcb_list[CurrentPCBno].regImg.SP;
			memcopy(pcb_list[pid].regImg.SS,pcb_list[CurrentPCBno].regImg.SS, SP_OFF);
			
			pcb_list[CurrentPCBno].regImg.AX = pid; 
			pcb_list[pid].regImg.AX = 0;
			pcb_list[pid].status = READY;
		}
	}
	else
	{
		/*表示分配子程序空间失败*/
		pcb_list[CurrentPCBno].regImg.AX = -1; 
	}
}

#define Semaphore_Max_Nr 10 /*定义信号量总量*/
typedef struct Semaphore
{
	int count;           /*该信号量的初始化*/
	int used;           /*信号量是否被占用*/
	int blocked_list_head; /*指明阻塞队列头部*/
}Semaphore;

Semaphore semaphore_list[Semaphore_Max_Nr];

extern int exchange(int *bolt, int key);

/*获取信号量，若获取失败，返回-1，否则，返回信号量id*/
int SemaGet(int value)
{
	int i;
	for(i = 0; i < Semaphore_Max_Nr; i++)
		if(semaphore_list[i].used == 0)
		{
			semaphore_list[i].used = 1;
			semaphore_list[i].count = value;
			return i;
		}
	return -1;
}

/*释放信号量*/
void SemaFree(int s)
{
	semaphore_list[s].used = 0;
}

/*锁住进程*/
void Block(int s)
{
	int i;
	int tmp = semaphore_list[s].blocked_list_head;
	
	pcb_list[CurrentPCBno].status = BLOCKED;
	if(tmp == 0)/*队列为空时，直接head=Current*/
	{
		semaphore_list[s].blocked_list_head = CurrentPCBno;
	}
	else{ 
		/*添加进队列末尾*/
		i = tmp;
		while(pcb_list[i].next != 0)
		{
			i = pcb_list[i].next;
		}
		pcb_list[i].next = CurrentPCBno;
	}
	Schedule();
}

/*释放进程*/
void WaitUp(int s)
{
	int head = semaphore_list[s].blocked_list_head;
	semaphore_list[s].blocked_list_head = pcb_list[head].next;
	pcb_list[head].status = READY;
	pcb_list[head].next = 0;
}

/*V操作*/
void V(int s)
{
	semaphore_list[s].count++;

	if(semaphore_list[s].count <= 0)
	{
		WaitUp(s);
	}
}

/*P操作*/
void P(int s)
{

	s = pcb_list[CurrentPCBno].regImg.DX;

	semaphore_list[s].count--;

	if(semaphore_list[s].count < 0)
	{
		Block(s);
	}	
}