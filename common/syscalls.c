#undef HZ
#undef TIMES

#include <time.h>
#include <stdio.h>

#define HZ 1000000


static long     Begin_Time,
                End_Time,
                User_Time;

void setStats (int a)
{
  if (a > 0)
    {
      Begin_Time = clock();
      return;
    }
  End_Time = clock();

  User_Time = End_Time - Begin_Time;
  printf ("User time %ld, HZ = %ld\n", User_Time, (long) HZ);
}
