#ifndef PACKETS_H
#define PACKETS_H

typedef nx_struct MoteMsg {
  nx_uint16_t NodeId;
  nx_uint8_t tempBool;
  nx_uint8_t lightBool;
  nx_uint8_t humidBool;
}MoteMsg_t;


enum {
  AM_RADIO = 6
};
#endif /* PACKETS_H */
