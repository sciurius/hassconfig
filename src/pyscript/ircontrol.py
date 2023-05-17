# ircontrol.py

@service
def ircontrol( device=None, command="power", remote="tasm11" ):

    if device == 'stb':
        device = 'vip1853'
    elif device == 'tv':
        device = 'philips_tv'
    elif device == 'audio':
        device = 'smsl_ad18'
    elif device == 'hdmiswitch':
        device = 'hdmi_switch'

    try:
        devmap = map[device]
    except:
        log.error( f"No such device: {device}" )
        return

    for cmd in command.split(' '):

        try:
            payload = devmap[cmd]
        except:
            log.error( f"No such command for {device}: {cmd}" )
            return

        log.info( f"IR: Sending {cmd} to {device}" )
        mqtt.publish( topic   = "cmnd/" + remote + "/irsend",
                     payload = payload )


map = {
  'philips_tv': {
    'key_0' : '{"Protocol":"RC6", "Bits":20,"Data":"0x00","DataLSB":"0x00","Repeat":0}',
    'key_1' : '{"Protocol":"RC6", "Bits":20,"Data":"0x01","DataLSB":"0x80","Repeat":0}',
    'key_2' : '{"Protocol":"RC6", "Bits":20,"Data":"0x02","DataLSB":"0x40","Repeat":0}',
    'key_3' : '{"Protocol":"RC6", "Bits":20,"Data":"0x03","DataLSB":"0xC0","Repeat":0}',
    'key_4' : '{"Protocol":"RC6", "Bits":20,"Data":"0x04","DataLSB":"0x20","Repeat":0}',
    'key_5' : '{"Protocol":"RC6", "Bits":20,"Data":"0x05","DataLSB":"0xA0","Repeat":0}',
    'key_6' : '{"Protocol":"RC6", "Bits":20,"Data":"0x06","DataLSB":"0x60","Repeat":0}',
    'key_7' : '{"Protocol":"RC6", "Bits":20,"Data":"0x07","DataLSB":"0xE0","Repeat":0}',
    'key_8' : '{"Protocol":"RC6", "Bits":20,"Data":"0x08","DataLSB":"0x10","Repeat":0}',
    'key_9' : '{"Protocol":"RC6", "Bits":20,"Data":"0x09","DataLSB":"0x90","Repeat":0}',
    'previous_channel' : '{"Protocol":"RC6", "Bits":20,"Data":"0x0A","DataLSB":"0x50","Repeat":0}',
    'power' : '{"Protocol":"RC6", "Bits":20,"Data":"0x0C","DataLSB":"0x30","Repeat":0}',
    'mute' : '{"Protocol":"RC6", "Bits":20,"Data":"0x0D","DataLSB":"0xB0","Repeat":0}',
    'info' : '{"Protocol":"RC6", "Bits":20,"Data":"0x0F","DataLSB":"0xF0","Repeat":0}',
    'volume_up' : '{"Protocol":"RC6", "Bits":20,"Data":"0x10","DataLSB":"0x08","Repeat":0}',
    'volume_down' : '{"Protocol":"RC6", "Bits":20,"Data":"0x11","DataLSB":"0x88","Repeat":0}',
    'channel_up' : '{"Protocol":"RC6", "Bits":20,"Data":"0x20","DataLSB":"0x04","Repeat":0}',
    'channel_down' : '{"Protocol":"RC6", "Bits":20,"Data":"0x21","DataLSB":"0x84","Repeat":0}',
    'fast_forward' : '{"Protocol":"RC6", "Bits":20,"Data":"0x28","DataLSB":"0x14","Repeat":0}',
    'rewind' : '{"Protocol":"RC6", "Bits":20,"Data":"0x2B","DataLSB":"0xD4","Repeat":0}',
    'pause' : '{"Protocol":"RC6", "Bits":20,"Data":"0x30","DataLSB":"0x0C","Repeat":0}',
    'stop' : '{"Protocol":"RC6", "Bits":20,"Data":"0x31","DataLSB":"0x8C","Repeat":0}',
    'play' : '{"Protocol":"RC6", "Bits":20,"Data":"0x32","DataLSB":"0x4C","Repeat":0}',
    'record' : '{"Protocol":"RC6", "Bits":20,"Data":"0x37","DataLSB":"0xEC","Repeat":0}',
    'next_source' : '{"Protocol":"RC6", "Bits":20,"Data":"0x38","DataLSB":"0x1C","Repeat":0}',
    'teletext' : '{"Protocol":"RC6", "Bits":20,"Data":"0x3C","DataLSB":"0x3C","Repeat":0}',
    'standby' : '{"Protocol":"RC6", "Bits":20,"Data":"0x3D","DataLSB":"0xBC","Repeat":0}',
    'option' : '{"Protocol":"RC6", "Bits":20,"Data":"0x40","DataLSB":"0x02","Repeat":0}',
    'closed_captions' : '{"Protocol":"RC6", "Bits":20,"Data":"0x46","DataLSB":"0x62","Repeat":0}',
    'subtitles' : '{"Protocol":"RC6", "Bits":20,"Data":"0x4B","DataLSB":"0xD2","Repeat":0}',
    'menu' : '{"Protocol":"RC6", "Bits":20,"Data":"0x54","DataLSB":"0x2A","Repeat":0}',
    'cursor_up' : '{"Protocol":"RC6", "Bits":20,"Data":"0x58","DataLSB":"0x1A","Repeat":0}',
    'cursor_down' : '{"Protocol":"RC6", "Bits":20,"Data":"0x59","DataLSB":"0x9A","Repeat":0}',
    'cursor_left' : '{"Protocol":"RC6", "Bits":20,"Data":"0x5A","DataLSB":"0x5A","Repeat":0}',
    'cursor_right' : '{"Protocol":"RC6", "Bits":20,"Data":"0x5B","DataLSB":"0xDA","Repeat":0}',
    'ok' : '{"Protocol":"RC6", "Bits":20,"Data":"0x5C","DataLSB":"0x3A","Repeat":0}',
    'red' : '{"Protocol":"RC6", "Bits":20,"Data":"0x6D","DataLSB":"0xB6","Repeat":0}',
    'green' : '{"Protocol":"RC6", "Bits":20,"Data":"0x6E","DataLSB":"0x76","Repeat":0}',
    'yellow' : '{"Protocol":"RC6", "Bits":20,"Data":"0x6F","DataLSB":"0xF6","Repeat":0}',
    'blue' : '{"Protocol":"RC6", "Bits":20,"Data":"0x70","DataLSB":"0x0E","Repeat":0}',
    'white' : '{"Protocol":"RC6", "Bits":20,"Data":"0x71","DataLSB":"0x8E","Repeat":0}',
    'exit' : '{"Protocol":"RC6", "Bits":20,"Data":"0x9F","DataLSB":"0xF9","Repeat":0}',
    'settings' : '{"Protocol":"RC6", "Bits":20,"Data":"0xBF","DataLSB":"0xFD","Repeat":0}',
    'guide' : '{"Protocol":"RC6", "Bits":20,"Data":"0xCC","DataLSB":"0x33","Repeat":0}',
    'channel_list' : '{"Protocol":"RC6", "Bits":20,"Data":"0xD2","DataLSB":"0x4B","Repeat":0}',
    'teletext' : '{"Protocol":"RC6", "Bits":20,"Data":"0xF1","DataLSB":"0x8F","Repeat":0}',
  },
  'hdmi_switch' : {
    'input1' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BF7B84","DataLSB":"0x2FDDE21","Repeat":0}',
    'input2' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BF5BA4","DataLSB":"0x2FDDA25","Repeat":0}',
    'input3' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BFDB24","DataLSB":"0x2FDDB24","Repeat":0}',
    'input4' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BFAA55","DataLSB":"0x2FD55AA","Repeat":0}',
    'in_auto' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BF9B64","DataLSB":"0x2FDD926","Repeat":0}',
    'ch_20' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BF33CC","DataLSB":"0x2FDCC33","Repeat":0}',
    'ch_51' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BFF906","DataLSB":"0x2FD9F60","Repeat":0}',
    'ch_71' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BF19E6","DataLSB":"0x2FD9867","Repeat":0}',
    'ch_auto' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BFD32C","DataLSB":"0x2FDCB34","Repeat":0}',
    'arc' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BFE916","DataLSB":"0x2FD9768","Repeat":0}',
  },
  'vip1853' : {
    'key_1' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,85000',
    'key_2' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,85000',
    'key_3' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,640,320,85000',
    'key_4' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,640,85000',
    'key_5' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,640,320,85000',
    'key_6' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,640,640,85000',
    'key_7' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,320,320,640,320,85000',
    'key_8' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,320,320,640,85000',
    'key_9' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,640,640,320,85000',
    'key_0' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,640,640,85000',
    'power' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,320,320,640,320,85000',
    'play_pause' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,640,640,320,320,640,320,85000',
    'rewind' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,320,320,320,320,640,640,320,85000',
    'fast_forward' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,640,640,320,320,640,85000',
    'stop' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,320,320,640,640,640,85000',
    'record' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,320,320,640,320,320,640,320,85000',
    'red' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,320,320,640,640,640,320,85000',
    'green' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,320,320,320,320,640,640,85000',
    'yellow' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,320,320,320,320,320,320,640,320,85000',
    'blue' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,320,320,320,320,320,320,640,85000',
    'up' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,640,320,320,640,85000',
    'down' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,640,640,640,320,85000',
    'left' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,320,320,640,640,85000',
    'right' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,320,320,320,320,640,85000',
    'ok' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,320,320,320,320,640,320,85000',
    'menu' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,320,320,640,640,640,320,85000',
    'tv' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,640,320,320,640,85000',
    'guide' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,320,320,640,640,85000',
    'radio' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,640,640,320,320,640,320,85000',
    'back' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,640,320,320,640,320,85000',
    'channel_up' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,640,320,320,640,640,320,85000',
    'channel_down' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,320,320,640,320,320,640,85000',
    'volume_up' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,320,320,320,320,640,320,85000',
    'volume_down' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,640,640,640,640,85000',
    'mute' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,320,320,640,320,320,320,320,640,85000',
    'source' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,320,320,320,320,640,640,320,85000',
    'text' : '56,320,640,640,640,320,320,640,640,640,640,320,320,320,320,320,320,320,320,320,320,320,320,320,320,640,640,640,640,320,320,640,640,320,85000',
  },
  'sony_mc' : {
    'power' : '{"Protocol":"SONY","Bits":12,"Data":"0xA81","DataLSB":"0x5081","Repeat":0}',
    'volume_up' : '{"Protocol":"SONY","Bits":12,"Data":"0x481","DataLSB":"0x2081","Repeat":0}',
    'volume_down' : '{"Protocol":"SONY","Bits":12,"Data":"0xC81","DataLSB":"0x3081","Repeat":0}',
    'bass_down' : '{"Protocol":"SONY","Bits":12,"Data":"0xEC6","DataLSB":"0x7063","Repeat":0}',
    'bass_up' : '{"Protocol":"SONY","Bits":12,"Data":"0x6C6","DataLSB":"0x6063","Repeat":0}',
    'treble_down' : '{"Protocol":"SONY","Bits":12,"Data":"0xAC6","DataLSB":"0x5063","Repeat":0}',
    'treble_up' : '{"Protocol":"SONY","Bits":12,"Data":"0x2C6","DataLSB":"0x4063","Repeat":0}',
    'forward' : '{"Protocol":"SONY","Bits":20,"Data":"0x8CB9C","DataLSB":"0x10D339","Repeat":0}',
    'rewind' : '{"Protocol":"SONY","Bits":20,"Data":"0xCB9C","DataLSB":"0xD339","Repeat":0}',
    'dbfb' : '{"Protocol":"SONY","Bits":12,"Data":"0x8C6","DataLSB":"0x1063","Repeat":0}',
    'display' : '{"Protocol":"SONY","Bits":12,"Data":"0xD21","DataLSB":"0xB084","Repeat":0}',
    'enter' : '{"Protocol":"SONY","Bits":20,"Data":"0x9AB9C","DataLSB":"0x90D539","Repeat":0}',
    'clear' : '{"Protocol":"SONY","Bits":20,"Data":"0xF0B9C","DataLSB":"0xF0D039","Repeat":0}',
    'sleep' : '{"Protocol":"SONY","Bits":12,"Data":"0x61","DataLSB":"0x86","Repeat":0}',
    'select' : '{"Protocol":"SONY","Bits":12,"Data":"0x461","DataLSB":"0x2086","Repeat":0}',
    'set' : '{"Protocol":"SONY","Bits":12,"Data":"0xA61","DataLSB":"0x5086","Repeat":0}',
    'md_video' : '{"Protocol":"SONY","Bits":12,"Data":"0x961","DataLSB":"0x9086","Repeat":0}',
    'cd' : '{"Protocol":"SONY","Bits":12,"Data":"0xA41","DataLSB":"0x5082","Repeat":0}',
    'tuner_band' : '{"Protocol":"SONY","Bits":12,"Data":"0x841","DataLSB":"0x1082","Repeat":0}',
    'mode' : '{"Protocol":"SONY","Bits":12,"Data":"0xE96","DataLSB":"0x7069","Repeat":0}',
    'stereo_mono' : '{"Protocol":"SONY","Bits":12,"Data":"0x856","DataLSB":"0x106A","Repeat":0}',
    'memory' : '{"Protocol":"SONY","Bits":12,"Data":"0x716","DataLSB":"0xE068","Repeat":0}',
    'play' : '{"Protocol":"SONY","Bits":12,"Data":"0xBC1","DataLSB":"0xD083","Repeat":0}',
    'pause' : '{"Protocol":"SONY","Bits":20,"Data":"0x9CB9C","DataLSB":"0x90D339","Repeat":0}',
    'stop' : '{"Protocol":"SONY","Bits":20,"Data":"0x1CB9C","DataLSB":"0x80D339","Repeat":0}',
    'tuning_previous' : '{"Protocol":"SONY","Bits":20,"Data":"0xCCB9C","DataLSB":"0x30D339","Repeat":0}',
    'tuning_next' : '{"Protocol":"SONY","Bits":20,"Data":"0x2CB9C","DataLSB":"0x40D339","Repeat":0}',
    'play_mode' : '{"Protocol":"SONY","Bits":12,"Data":"0x371","DataLSB":"0xC08E","Repeat":0}',
    'repeat' : '{"Protocol":"SONY","Bits":12,"Data":"0x351","DataLSB":"0xC08A","Repeat":0}',
  },
  'smsl_ad18' : {
    'power' : '{"Protocol":"NEC", "Bits":32,"Data":"0x807F","DataLSB":"0x01FE","Repeat":0}',
    'mute' : '{"Protocol":"NEC", "Bits":32,"Data":"0x906F","DataLSB":"0x09F6","Repeat":0}',
    'volume_up' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BF","DataLSB":"0x02FD","Repeat":0}',
    'a_left' : '{"Protocol":"NEC", "Bits":32,"Data":"0xC03F","DataLSB":"0x03FC","Repeat":0}',
    'settings' : '{"Protocol":"NEC", "Bits":32,"Data":"0x20DF","DataLSB":"0x04FB","Repeat":0}',
    'a_right' : '{"Protocol":"NEC", "Bits":32,"Data":"0xA05F","DataLSB":"0x05FA","Repeat":0}',
    'volume_down' : '{"Protocol":"NEC", "Bits":32,"Data":"0x609F","DataLSB":"0x06F9","Repeat":0}',
    'input' : '{"Protocol":"NEC", "Bits":32,"Data":"0xE01F","DataLSB":"0x07F8","Repeat":0}',
    'fn' : '{"Protocol":"NEC", "Bits":32,"Data":"0x10EF","DataLSB":"0x08F7","Repeat":0}',
    'b_power' : '{"Protocol":"NEC", "Bits":32,"Data":"0x807F","DataLSB":"0x01FE","Repeat":0}',
    'b_mute' : '{"Protocol":"NEC", "Bits":32,"Data":"0x906F","DataLSB":"0x09F6","Repeat":0}',
    'b_up' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BF","DataLSB":"0x02FD","Repeat":0}',
    'b_left' : '{"Protocol":"NEC", "Bits":32,"Data":"0xC03F","DataLSB":"0x03FC","Repeat":0}',
    'b_enter' : '{"Protocol":"NEC", "Bits":32,"Data":"0x20DF","DataLSB":"0x04FB","Repeat":0}',
    'b_right' : '{"Protocol":"NEC", "Bits":32,"Data":"0xA05F","DataLSB":"0x05FA","Repeat":0}',
    'b_down' : '{"Protocol":"NEC", "Bits":32,"Data":"0x609F","DataLSB":"0x06F9","Repeat":0}',
    'b_input' : '{"Protocol":"NEC", "Bits":32,"Data":"0xE01F","DataLSB":"0x07F8","Repeat":0}',
    'b_fn' : '{"Protocol":"NEC", "Bits":32,"Data":"0x10EF","DataLSB":"0x08F7","Repeat":0}',
    'c_power' : '{"Protocol":"NEC", "Bits":32,"Data":"0x807F","DataLSB":"0x01FE","Repeat":0}',
    'c_mute' : '{"Protocol":"NEC", "Bits":32,"Data":"0x906F","DataLSB":"0x09F6","Repeat":0}',
    'c_up' : '{"Protocol":"NEC", "Bits":32,"Data":"0x40BF","DataLSB":"0x02FD","Repeat":0}',
    'c_left' : '{"Protocol":"NEC", "Bits":32,"Data":"0xC03F","DataLSB":"0x03FC","Repeat":0}',
    'c_enter' : '{"Protocol":"NEC", "Bits":32,"Data":"0x20DF","DataLSB":"0x04FB","Repeat":0}',
    'c_right' : '{"Protocol":"NEC", "Bits":32,"Data":"0xA05F","DataLSB":"0x05FA","Repeat":0}',
    'c_down' : '{"Protocol":"NEC", "Bits":32,"Data":"0x609F","DataLSB":"0x06F9","Repeat":0}',
    'c_mode' : '{"Protocol":"NEC", "Bits":32,"Data":"0xE01F","DataLSB":"0x07F8","Repeat":0}',
    'c_fn' : '{"Protocol":"NEC", "Bits":32,"Data":"0x10EF","DataLSB":"0x08F7","Repeat":0}',
  },
  'squeezebox' : {
    'home' : '{"Protocol":"NEC", "Bits":32,"Data":"0x768922DD","DataLSB":"0x6E9144BB","Repeat":0}',
    'light' : '{"Protocol":"NEC", "Bits":32,"Data":"0x7689B847","DataLSB":"0x6E911DE2","Repeat":0}',
    'power' : '{"Protocol":"NEC", "Bits":32,"Data":"0x768940BF","DataLSB":"0x6E9102FD","Repeat":0}',
    'plus' : '{"Protocol":"NEC", "Bits":32,"Data":"0x7689609F","DataLSB":"0x6E9106F9","Repeat":0}',
    'play' : '{"Protocol":"NEC", "Bits":32,"Data":"0x768910EF","DataLSB":"0x6E9108F7","Repeat":0}',
    'up' : '{"Protocol":"NEC", "Bits":32,"Data":"0x7689E01F","DataLSB":"0x6E9107F8","Repeat":0}',
    'left' : '{"Protocol":"NEC", "Bits":32,"Data":"0x7689906F","DataLSB":"0x6E9109F6","Repeat":0}',
    'right' : '{"Protocol":"NEC", "Bits":32,"Data":"0x7689D02F","DataLSB":"0x6E910BF4","Repeat":0}',
    'down' : '{"Protocol":"NEC", "Bits":32,"Data":"0x7689B04F","DataLSB":"0x6E910DF2","Repeat":0}',
    'voldown' : '{"Protocol":"NEC", "Bits":32,"Data":"0x768900FF","DataLSB":"0x6E9100FF","Repeat":0}',
    'volup' : '{"Protocol":"NEC", "Bits":32,"Data":"0x7689807F","DataLSB":"0x6E9101FE","Repeat":0}',
    'prev' : '{"Protocol":"NEC", "Bits":32,"Data":"0x7689C03F","DataLSB":"0x6E9103FC","Repeat":0}',
    'pause' : '{"Protocol":"NEC", "Bits":32,"Data":"0x768920DF","DataLSB":"0x6E9104FB","Repeat":0}',
    'next' : '{"Protocol":"NEC", "Bits":32,"Data":"0x7689A05F","DataLSB":"0x6E9105FA","Repeat":0}',
  },
}
