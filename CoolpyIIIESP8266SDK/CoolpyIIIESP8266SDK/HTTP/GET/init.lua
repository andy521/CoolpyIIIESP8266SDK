	print("CoolpyIII V2.0 ESP8266_SDK HTTP GET")
	server = "i.icoolpy.com"--������������IP��ַ
	port = 1337--��Ʀƽ̨����˿�
	ukey = "0946ed70-2a46-48e3-b096-24611f74fae1"--UserKey�û���Կ(�ظ���)
	hub = 1--Hub ID(�ظ���)
	cnode = 10--Node ID(�ظ���)
	--(��оƬ���ӻ�����)
	wifiPoint = "YMS_805_1"--����·�����ȵ���
	wifiPwd = "yms#0805"--����·��������
    
	wifiok = 0;
	tmr.stop(0);
	tmr.stop(1);
	local str=wifi.ap.getmac();
    local ssidTemp=string.format("%s%s%s",string.sub(str,10,11),string.sub(str,13,14),string.sub(str,16,17));
    wifi.setmode(wifi.STATIONAP)
    
    local cfg={}
    cfg.ssid="ESP8266_"..ssidTemp;
    cfg.pwd="12345678"
    wifi.ap.config(cfg)
     cfg={}
     cfg.ip="192.168.4.1";
     cfg.netmask="255.255.255.0";
     cfg.gateway="192.168.4.1";
     wifi.ap.setip(cfg);
     
     wifi.sta.config(wifiPoint,wifiPwd)
     wifi.sta.connect()
     
     local cnt = 0
     gpio.mode(0,gpio.OUTPUT);
     tmr.alarm(0, 1000, 1, function() 
         if (wifi.sta.getip() == nil) and (cnt < 20) then 
             print("Trying Connect to Router, Waiting...")
             cnt = cnt + 1 
                  if cnt%2==1 then gpio.write(0,gpio.HIGH);
                  else gpio.write(0,gpio.LOW); end
         else 
             tmr.stop(0);
			 wifiok =1;
             print("Soft AP started")
             print("MAC:"..wifi.ap.getmac().."\r\nIP:"..wifi.ap.getip());
             cnt = nil;cfg=nil;str=nil;ssidTemp=nil;
             collectgarbage()
         end 
     end)
	
	--ÿ��10�������������һ������
	tmr.alarm(1, 10000, 1, function() 
		if(wifiok == 1) then --�ж�wifi�Ƿ��Ѿ��ɹ�������·�������ӻ�����
			sk=net.createConnection(net.TCP, 0)
			sk:on("connection", function(conn) toget() end)
			sk:on("disconnection", function(conn, pl) print("disconnection") sk:close() end)
			sk:on("receive", function(conn, pl) 
				sk:close()
				--��ʾ��������ȡ��������Ϣ
				print(pl) 
			end) 
			sk:connect(port,server)
		end
		
		function toget()			
			sk:send("GET /v1.0/hub/"..hub.."/node/"..cnode.."/datapoint HTTP/1.1\r\n"
			.."Host: "..server.."\r\n"
			.."U-ApiKey:"..ukey.."\r\n"
			.."Cache-Control: no-cache\r\n\r\n")
		end
	end)	
