object Form2: TForm2
  Left = 2522
  Top = 201
  BorderStyle = bsToolWindow
  Caption = #1055#1086#1084#1086#1097#1100
  ClientHeight = 590
  ClientWidth = 664
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object redt1: TRichEdit
    Left = 0
    Top = 161
    Width = 664
    Height = 388
    Align = alClient
    Color = clNavy
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMenuBar
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      'Usage: goodbyedpi.exe [OPTION...]'
      ' -p          block passive DPI'
      ' -q          block QUIC/HTTP3'
      ' -r          replace Host with hoSt'
      ' -s          remove space between host header and its value'
      ' -m          mix Host header case (test.com -> tEsT.cOm)'
      ' -f <value>  set HTTP fragmentation to value'
      
        ' -k <value>  enable HTTP persistent (keep-alive) fragmentation a' +
        'nd set it to value'
      
        ' -n          do not wait for first segment ACK when -k is enable' +
        'd'
      ' -e <value>  set HTTPS fragmentation to value'
      
        ' -a          additional space between Method and Request-URI (en' +
        'ables -s, may break sites)'
      
        ' -w          try to find and parse HTTP traffic on all processed' +
        ' ports (not only on port 80)'
      
        ' --port        <value>    additional TCP port to perform fragmen' +
        'tation on (and HTTP tricks with -w)'
      
        ' --ip-id       <value>    handle additional IP ID (decimal, drop' +
        ' redirects and TCP RSTs with this ID).'
      
        '                          This option can be supplied multiple t' +
        'imes.'
      
        ' --dns-addr    <value>    redirect UDP DNS requests to the suppl' +
        'ied IP address (experimental)'
      
        ' --dns-port    <value>    redirect UDP DNS requests to the suppl' +
        'ied port (53 by default)'
      
        ' --dnsv6-addr  <value>    redirect UDPv6 DNS requests to the sup' +
        'plied IPv6 address (experimental)'
      
        ' --dnsv6-port  <value>    redirect UDPv6 DNS requests to the sup' +
        'plied port (53 by default)'
      ' --dns-verb               print verbose DNS redirection messages'
      
        ' --blacklist   <txtfile>  perform circumvention tricks only to h' +
        'ost names and subdomains from'
      
        '                          supplied text file (HTTP Host/TLS SNI)' +
        '.'
      
        '                          This option can be supplied multiple t' +
        'imes.'
      
        ' --allow-no-sni           perform circumvention if TLS SNI can'#39't' +
        ' be detected with --blacklist enabled.'
      
        ' --frag-by-sni            if SNI is detected in TLS packet, frag' +
        'ment the packet right before SNI value.'
      
        ' --set-ttl     <value>    activate Fake Request Mode and send it' +
        ' with supplied TTL value.'
      
        '                          DANGEROUS! May break websites in unexp' +
        'ected ways. Use with care (or --blacklist).'
      
        ' --auto-ttl    [a1-a2-m]  activate Fake Request Mode, automatica' +
        'lly detect TTL and decrease'
      
        '                          it based on a distance. If the distanc' +
        'e is shorter than a2, TTL is decreased'
      
        '                          by a2. If it'#39's longer, (a1; a2) scale ' +
        'is used with the distance as a weight.'
      
        '                          If the resulting TTL is more than m(ax' +
        '), set it to m.'
      
        '                          Default (if set): --auto-ttl 1-4-10. A' +
        'lso sets --min-ttl 3.'
      
        '                          DANGEROUS! May break websites in unexp' +
        'ected ways. Use with care (or --blacklist).'
      
        ' --min-ttl     <value>    minimum TTL distance (128/64 - TTL) fo' +
        'r which to send Fake Request'
      '                          in --set-ttl and --auto-ttl modes.'
      
        ' --wrong-chksum           activate Fake Request Mode and send it' +
        ' with incorrect TCP checksum.'
      
        '                          May not work in a VM or with some rout' +
        'ers, but is safer than set-ttl.'
      
        ' --wrong-seq              activate Fake Request Mode and send it' +
        ' with TCP SEQ/ACK in the past.'
      
        ' --native-frag            fragment (split) the packets by sendin' +
        'g them in smaller packets, without'
      
        '                          shrinking the Window Size. Works faste' +
        'r (does not slow down the connection)'
      '                          and better.'
      
        ' --reverse-frag           fragment (split) the packets just as -' +
        '-native-frag, but send them in the'
      
        '                          reversed order. Works with the website' +
        's which could not handle segmented'
      
        '                          HTTPS TLS ClientHello (because they re' +
        'ceive the TCP flow "combined").'
      
        ' --fake-from-hex <value>  Load fake packets for Fake Request Mod' +
        'e from HEX values (like 1234abcDEF).'
      
        '                          This option can be supplied multiple t' +
        'imes, in this case each fake packet'
      
        '                          would be sent on every request in the ' +
        'command line argument order.'
      
        ' --fake-with-sni <value>  Generate fake packets for Fake Request' +
        ' Mode with given SNI domain name.'
      
        '                          The packets mimic Mozilla Firefox 130 ' +
        'TLS ClientHello packet'
      
        '                          (with random generated fake SessionID,' +
        ' key shares and ECH grease).'
      
        '                          Can be supplied multiple times for mul' +
        'tiple fake packets.'
      
        ' --fake-gen <value>       Generate random-filled fake packets fo' +
        'r Fake Request Mode, value of them'
      '                          (up to 30).'
      
        ' --fake-resend <value>    Send each fake packet value number of ' +
        'times.'
      '                          Default: 1 (send each packet once).'
      
        ' --max-payload [value]    packets with TCP payload data more tha' +
        'n [value] won'#39't be processed.'
      
        '                          Use this option to reduce CPU usage by' +
        ' skipping huge amount of data'
      
        '                          (like file transfers) in already estab' +
        'lished sessions.'
      
        '                          May skip some huge HTTP requests from ' +
        'being processed.'
      '                          Default (if set): --max-payload 1200.'
      ''
      ''
      'LEGACY modesets:'
      ' -1          -p -r -s -f 2 -k 2 -n -e 2 (most compatible mode)'
      
        ' -2          -p -r -s -f 2 -k 2 -n -e 40 (better speed for HTTPS' +
        ' yet still compatible)'
      ' -3          -p -r -s -e 40 (better speed for HTTP and HTTPS)'
      ' -4          -p -r -s (best speed)'
      ''
      'Modern modesets (more stable, more compatible, faster):'
      ' -5          -f 2 -e 2 --auto-ttl --reverse-frag --max-payload'
      ' -6          -f 2 -e 2 --wrong-seq --reverse-frag --max-payload'
      
        ' -7          -f 2 -e 2 --wrong-chksum --reverse-frag --max-paylo' +
        'ad'
      
        ' -8          -f 2 -e 2 --wrong-seq --wrong-chksum --reverse-frag' +
        ' --max-payload'
      
        ' -9          -f 2 -e 2 --wrong-seq --wrong-chksum --reverse-frag' +
        ' --max-payload -q (this is the default)'
      ''
      
        ' Note: combination of --wrong-seq and --wrong-chksum generates t' +
        'wo different fake packets.')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object pnl1: TPanel
    Left = 0
    Top = 549
    Width = 664
    Height = 41
    Align = alBottom
    TabOrder = 1
    object btn1: TButton
      Left = 360
      Top = 8
      Width = 139
      Height = 25
      Caption = #1057#1090#1088#1072#1085#1080#1094#1072' GoodByeDPI'
      TabOrder = 0
      OnClick = btn1Click
    end
    object btn2: TButton
      Left = 504
      Top = 8
      Width = 137
      Height = 25
      Caption = #1057#1090#1088#1072#1085#1080#1094#1072' '#1087#1088#1086#1075#1088#1072#1084#1084#1099
      TabOrder = 1
      OnClick = btn2Click
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 0
    Width = 664
    Height = 161
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 2
  end
end
