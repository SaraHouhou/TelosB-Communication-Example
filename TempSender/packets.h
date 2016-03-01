#ifndef PACKETS_H
#define PACKETS_H

typedef nx_struct TempMsg {
  nx_uint16_t NodeId;
  nx_uint8_t tempBool;
}TempMsg_t;

typedef nx_struct LightMsg {
  nx_uint16_t NodeId;
  nx_uint8_t lightBool;
} LightMsg_t;

enum {
  AM_RADIO = 6
};
#endif /* PACKETS_H */
