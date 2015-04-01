/*程序源代码（myInt33.c）*/
/*time: 2014年4月19日14:49:19
/*Auth: 蔡燕芝
/*Describe: 实现33号中断的 1 2 3 4 功能号的子程序*/

/*将一个字符串中的小字母变为大写字母*/  
void myprintf(char *Message);          
void upper(char *Message){        
   int i=0;
   while(Message[i]) {
     if (Message[i]>='a'&&Message[i]<='z')  
      Message[i]=Message[i]+'A'-'a';
	  i++;
   }
}

/*将一个字符串中的大字母变为小写字母*/   
void lowwer(char *Message)
{
  int i=0;
   while(Message[i]) {
     if (Message[i]>='A'&&Message[i]<='Z')  
      Message[i]=Message[i]-'A'+'a';
    i++;
  }
}

/*数值num变成对应的数字字符串存储在Message中*/
void int2Chars(char* Message, int num)
{
  int index = 0;
  int i = 0;
  int result[15];
  while(num)
  {
    result[index++] = num%10;
    num /= 10;
  }

  for(i = 0; i < index ; i++)
    Message[i] = result[index - 1 - i] + '0';
  Message[index] = '\0';
}

/*将一个数字字符串转变对应的数值*/
int chars2Int(char *Message)
{
  int i=0;
  int result = 0;
  while(Message[i]) {
      if(i!=0)
        result *= 10;

      result += (Message[i] - '0');
      i++;
  }
  return result;
}
