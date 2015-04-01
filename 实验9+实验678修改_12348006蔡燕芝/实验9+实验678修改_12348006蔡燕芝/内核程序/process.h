/*Kernel.h*/
/*内核数据结构类型和数据结构*/
/*create by 蔡燕芝*/
/*last edited time : 2014年5月19日21:18:31*/
#define MAX_NrPCB 50
int CurrentPCBno = 0; /*当前进程号*/
int processNum = 0; /*进程计数*/
int baseSeg = 0x3000; /*每个进程的段地址 = baseSeg + SegLength*pid */
int SegLength = 0x400;   /*每一段的段地址长度*/
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


typedef enum PCB_Status{READY,GO = 1,EXIT,RUNNING, BLOCKED,SUSPENDED}PCB_Status;

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
	if(CurrentPCBno == 0)
	{
		pcb_list[CurrentPCBno].used = 1;
		pcb_list[CurrentPCBno].status = READY;  /*若是刚从内核进入，让其处于ready*/
	}

	if(pcb_list[CurrentPCBno].status == RUNNING)
		pcb_list[CurrentPCBno].status = READY;

	while(1)             /*调度算法：顺序轮转*/
	{
		CurrentPCBno = CurrentPCBno + 1;
		if(CurrentPCBno > MAX_NrPCB)
			CurrentPCBno = 0;

		if(pcb_list[CurrentPCBno].used == 1  && pcb_list[CurrentPCBno].status == GO)
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
	pcb->next = 0;
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
	pcb->status = GO;
}

/*运行新程序*/
int runProg(char *filename)
{
	int pid;
	int tmp;
	pid = requirePCB();/*申请pcb块，失败返回-1*/
	if(pid != -1)
	{
		currentSeg = baseSeg + (pid - 1)*SegLength;/*确定程序的段地址*/
		tmp  = loadProg(filename);   /*加载程序,失败返回-1*/
		if(tmp != -1)
		{
			createProcess(pid);       /*创建进程*/
			return pid;
		}
		else
		{
			pcb_list[pid].used = 0;  /*失败，释放pcb*/
			return tmp;
		}
	}
	else
		return pid;
}

/*申请PCB块*/
int requirePCB()
{
	int i;
	for(i = 1; i < MAX_NrPCB; i++)
	{
		if(pcb_list[i].used == 0)
		{
			pcb_list[i].status = EXIT;
			pcb_list[i].used = 1;
			return i;
		}
	}
	return -1;
}
/*创建新的进程*/
int createProcess(int process_id)
{
	initPCB( &pcb_list[process_id] ,process_id, currentSeg, SP_OFF); /*初始化pcb块*/
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
	
	if( fpid != -1 )
	{
		pcb_list[fpid].status = READY;
		pcb_list[fpid].regImg.AX = ch; /*记录退出信息*/
		stack_id = (pcb_list[CurrentPCBno].regImg.SS - SS_baseSeg)/SP_OFF;
		STACK_LIST[stack_id] = 0;
	}

	pcb_list[CurrentPCBno].used = 0;
	pcb_list[CurrentPCBno].status = EXIT;
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

void copyFatherToSon(int father, int son)
{
	pcb_list[son].regImg.SP = pcb_list[father].regImg.SP;
	pcb_list[son].regImg.GS = pcb_list[father].regImg.GS;
	pcb_list[son].regImg.FS = pcb_list[father].regImg.FS;
	pcb_list[son].regImg.ES = pcb_list[father].regImg.ES;
	pcb_list[son].regImg.DS = pcb_list[father].regImg.DS;
	pcb_list[son].regImg.DI = pcb_list[father].regImg.DI;
	pcb_list[son].regImg.SI = pcb_list[father].regImg.SI;
	pcb_list[son].regImg.BP = pcb_list[father].regImg.BP;
	pcb_list[son].regImg.BX = pcb_list[father].regImg.BX;
	pcb_list[son].regImg.DX = pcb_list[father].regImg.DX;
	pcb_list[son].regImg.CX = pcb_list[father].regImg.CX;
	pcb_list[son].regImg.IP = pcb_list[father].regImg.IP;
	pcb_list[son].regImg.CS = pcb_list[father].regImg.CS;
	pcb_list[son].regImg.Flags = pcb_list[father].regImg.Flags;
	pcb_list[son].fpid = father;
	pcb_list[son].pid = son;
}
/*
 1）在父进程中，fork返回新创建子进程的进程ID;
 2）在子进程中，fork返回0;
 3）如果出现错误，fork返回一个负值;
*/
 int fork() /*-1表示分配子程序空间失败， -2表示分配栈空间失败 */
{
	int stack_id;
	pid = requirePCB();/*申请pcb块*/

	if(pid)
	{
		/*申请 分配栈内存空间*/
		stack_id = requrireStackMemory();
		if(stack_id == -1)
		{
			/*分配栈空间失败*/
			pcb_list[pid].used = 0;
			pcb_list[CurrentPCBno].regImg.AX = -1; 
		}
		else
		{
			copyFatherToSon(CurrentPCBno, pid);/*复制父进程的状态信息给子进程*/
			
			pcb_list[pid].regImg.SS = SS_baseSeg + stack_id * SS_Len;    /*确定SS*/

			memcopy(pcb_list[pid].regImg.SS,pcb_list[CurrentPCBno].regImg.SS, SP_OFF);/*复制父进程的栈区给子进程*/
			
			pcb_list[CurrentPCBno].regImg.AX = pid; /*父进程返回子进程id*/
			pcb_list[pid].regImg.AX = 0; /*子进程返回0*/
			pcb_list[pid].status = READY;
			pcb_list[pid].next = 0; 
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

	s = pcb_list[CurrentPCBno].regImg.DX;/*由于在P()之前保存了PCB表*/

	semaphore_list[s].count--;

	if(semaphore_list[s].count < 0)
	{
		Block(s);
	}	
}