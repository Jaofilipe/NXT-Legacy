%----------------------------------------------------
%  LEGO MINDSTORMS NXT BLUETOOTH CONTROL
%           by: Jo�o Filipe
%         jaofilipe14@gmail.com
%----------------------------------------------------

COM_CloseNXT all %Termina liga��es existentes com dispositivos NXT
clc
clear all
close all

COM_MakeBTConfigFile(); %load config do bluetooth
fprintf("Inicializando....\n")
try
    hNXT = COM_OpenNXT('bluetooth.ini');%inicializar o link bluetooth
    COM_SetDefaultNXT(hNXT); %escolher o nxt
    
    %abrir sensores do NXT
    OpenNXT2Color( SENSOR_1, 'FULL' ); %sensor de cor na porta 1
    OpenSwitch(SENSOR_2);
    OpenUltrasonic(SENSOR_3);          %sensor de ultrassons na porta 3
    %OpenUltrasonic(SENSOR_4);          %sensor de ultrassons na porta 4
    
    %handles dos motores
    ma = NXTMotor([MOTOR_A]); %motor A
    mb = NXTMotor([MOTOR_B]); %motor B
    %definir rota��o cont�nua dos motores
    ma.TachoLimit = 0; 
    mb.TachoLimit = 0;
    %definir velocidade base dos motores
    ma.Power = 0;
    mb.Power = 0;
    %enviar dados para os motores
    ma.SendToNXT()
    mb.SendToNXT()
    
    %iniciar o joystick com forcefeedback se possivel
    %joy = vrjoystick(1,'forcefeedback'); 
    %mensagem de sucesso de inicializa��o
    NXT_PlaySoundFile('Alarm.rso',0);
    fprintf("Sucesso\n")
    pause(300);

catch ME
    %se algum erro acontecer na inicializa��o informar o user
    if ME.identifier(8:24) == "RWTHMindstormsNXT" 
        %se errou na inicializa��o do NXT
        fprintf("Falha na inicializa��o de NXT...\n Limpando as handles....\n")
        COM_CloseNXT all
        return
    elseif ME.identifier == "sl3d:vrjoystick:notconnected" 
        %se n�o h� joystick ligado ao pc
        fprintf("Falha na leitura do joystick...\nLigue o joystick e pressione enter....\n")
        pause()
        %joy =vrjoystick(1,'forcefeedback');
    end
end

while 1
    pause(0.1) %pausa para n�o criar overflow no bluetooth
    %testar a fun��o read(joy) primariamente de forma a confirmar o
    %funcionamento correto do programa para cada bot�o

    [eixos,botoes] = read(joy); %ler os bot�es do joystick
    
    %no caso de o joystick n�o originar valores inteiros
    lateral = round(eixos(1)); 
    frontal = -1*round(eixos(2));
    
    %equa��es de movimento para o joystick (verificar os bot�es primeiro)
    ma.Power= max(-100,min(100,((-0.5*botoes(6)+1)*(botoes(5)*100 + 1)*(30*(frontal) - 20*(lateral)))));
    mb.Power= max(-100,min(100,((-0.5*botoes(6)+1)*(botoes(5)*100 + 1)*(30*(frontal) + 20*(lateral)))));
    
    %Sele��o de tarefas a executar quando um bot�o � pressionado
    
    if botoes(1) %bot�o para seguir linha se existir sensor de luz
        if GetNXT2Color( SENSOR_1 ) == "BLACK"
            ma.Power = -5;
            mb.Power = 25;
        else
            ma.Power = 25;
            mb.Power = -5;
        end
    elseif botoes(2) %bot�o para sensor de proximidade
        dist=GetUltrasonic(SENSOR_3);
        if ( dist >= 0 && dist<= 60)
            freq = round((60-dist)*30 + 200);
            NXT_PlayTone(freq,100);
        else
            NXT_PlayTone(200,100);
        end
    elseif botoes(8) %bot�o para sensor de proximidade
        %voltage = NXT_GetBatteryLevel(hNXT)
        dist=GetUltrasonic(SENSOR_3);
        if ( dist >= 0 && dist<= 60)
            freq = round((60-dist)*30 + 200);
            NXT_PlayTone(freq,100);
        else
            NXT_PlayTone(200,100);
        end
    end
    if GetSwitch(SENSOR_2)
        ma.Power = -20;
        mb.Power = -20;
        ma.SendToNXT(); 
        mb.SendToNXT();
        NXT_PlayTone(500,100);
        pause(1)   
    end
    %enviar dados dos motores para o nxt
    ma.SendToNXT() 
    mb.SendToNXT()
end