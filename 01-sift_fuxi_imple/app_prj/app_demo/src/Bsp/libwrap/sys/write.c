/* See LICENSE of license details. */

#include <stdint.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>

#include "platform.h"
#include "stub.h"

extern ST_UART_ATTR  stUartObj;

ssize_t _write(int fd, const void* ptr, size_t len)
{
  const uint8_t * current = (const char *)ptr;
  uint32_t Data_len = len;

  if (isatty(fd))
  {
    for (size_t jj = 0; jj < len; jj++)
    {
    	  UartByteSend(&stUartObj, current[jj]);
          if (current[jj] == '\n')
          {
    	      UartByteSend(&stUartObj, '\r');
          }
    }
    return len;
  }

  return _stub(EBADF);
}
