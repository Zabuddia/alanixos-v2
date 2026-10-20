{
  hub = "alan-big-nixos";
  endpoint = "wireguard.fifefin.com:51820";
  port = 51820;

  peers = {
    alan-big-nixos = {
      address = "10.100.0.1";
      publicKey = "N7ZJS7K5oTlfRl0eDg0hcbWJXtyinHMDg5codoHubAg=";
    };
    alan-framework = {
      address = "10.100.0.2";
      publicKey = "CPgaziLt9mszNM+ws9FqA+j24FJoXI3voRdd+IZqyRE=";
    };
    alan-framework-laptop = {
      address = "10.100.0.3";
      publicKey = "42X/dFZ5DMhtfdlhNxSife5vbDJk1q0x84/NU7+28gM=";
    };
    alan-home = {
      address = "10.100.0.4";
      publicKey = "DW9410EVNL3StWTMXlZQjupzposPOblWjjetlzDoNkc=";
    };
    alan-node = {
      address = "10.100.0.5";
      publicKey = "4BDnRN6t6X+fz8gTeYgRjw7p47luwLY6y+BFkXFEc2k=";
    };
    alan-optiplex = {
      address = "10.100.0.6";
      publicKey = "t/1kMO1teTzffhdo1jozYWoEMimLrXNm726KY/k603c=";
    };
    alan-tv = {
      address = "10.100.0.7";
      publicKey = "/9LFcpLU/NbZ3Uxh21uthOGOdRxbQNhyTVL4Rp7+TTs=";
    };
    fife-tv = {
      address = "10.100.0.8";
      publicKey = "BfkoesQqw760koMzeBvq8W9Rpa/7A0KOuuoplO7xxy0=";
    };
    randy-big-nixos = {
      address = "10.100.0.9";
      publicKey = "ii5JigjlHp7rL0v3hXSEsqPl3Zc06CbE76PexpPYbDg=";
    };
  };
}
