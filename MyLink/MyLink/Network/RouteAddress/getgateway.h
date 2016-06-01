#ifndef __GETGATEWAY_H__
#define __GETGATEWAY_H__

/* getdefaultgateway() :
 * return value :
 *    0 : success
 *   -1 : failure    */
unsigned char * getdefaultgateway(in_addr_t * addr);

#endif