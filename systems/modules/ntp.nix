{ config, ...}:
{
  services.chrony = {
    enable = true;
    servers = [
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
    ];
  };
}
