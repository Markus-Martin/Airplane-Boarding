% Airplane boarding simulation
%
% Made by Markus Martin
% November 2019

%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%--------------------------------- Inputs --------------------------------%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
NumPassengers = 300;        % Number of passengers
RandVal = 10;               % Max time for passengers to load baggage
SPR = 4;                    % Seats Per Row
RPSec = 1;                  % Rows per second (Speed of walking passengers)
SwitchTime = [3 5];         % Time for each type of 'switch', 1 or 2 person
IncludeBest = 0;            % Whether to include 'best method' on graph


%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%----------- Constant Values / Definitions / Memory Allocation -----------%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
Repeats = 20; % Number of times to repeat the computational experiment
PassWait = RandVal*rand(Repeats,NumPassengers); % Passenger rand wait time
PassWaitR = PassWait; % Something that can be used to reset PassWait
NumOrder = 5; % Number of different ordering methods
minTime = inf;
Min = 0;
if IncludeBest == 1
    Data = zeros(NumOrder+1,Repeats); % Data from each repetition
    Average = zeros(1,NumOrder+1);
    Spread = zeros(1,NumOrder+1);
    Names = {'Random','Ascending','Descending','Modified Best','Best','Baggage Holding'};
else
    Data = zeros(NumOrder,Repeats); % Data from each repetition
    Average = zeros(1,NumOrder);
    Spread = zeros(1,NumOrder);
    Names = {'Random','Ascending','Descending','Modified Best','Baggage Holding'};
end


%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%---------------------- Setting Initial Conditions -----------------------%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
for j = 0:NumOrder % Different order rotations
    if IncludeBest == 1 || j ~= 4 % Don't run for j=4 if includebest = 0
        if j == 5
            PassWait = PassWaitR*0; % 0 Pass wait for baggage holding
        else
            PassWait = PassWaitR;
        end
        for k = 1:Repeats
            
            TotTime = 0; % Total time counter
            TotRemoved = 0; % Total passengers removed from hallway
            WalkWait = zeros(1,NumPassengers); % Wait time for walking
            SwitchWait = zeros(1,NumPassengers);
            
            % Deciding order of passenger
            % The code for a randomised order
            if j == 5
                PassOrder = BoardingType(NumPassengers,SPR,0);
            else
                PassOrder = BoardingType(NumPassengers,SPR,j);
            end
            
            
            % First passenger is special since he can go as far as he wants
            CurPassLoc = zeros(1,NumPassengers); % Current passenger location
            FuturePassLoc = zeros(1,NumPassengers); % Future passenger location
            for i = 2:NumPassengers
                CurPassLoc(i) = CurPassLoc(i-1)-1;
            end
            FuturePassLoc = CurPassLoc;
            
            % -------------------------------------------------------------
            % Calculating swtich wait times
            if SPR == 6
                for i = 1:NumPassengers
                    C = 0; % Counter for how many passengers there are for switch
                    if mod(PassOrder(i),SPR) == 1 % Left Window
                        for ii = 1:i
                            if PassOrder(i)+1 == PassOrder(ii)
                                C = C + 1;
                            else if PassOrder(i)+2 == PassOrder(ii)
                                    C = C + 1;
                                end
                            end
                        end
                    else if mod(PassOrder(i),SPR) == 2 % Left Middle
                            for ii = 1:i
                                if PassOrder(i)+1 == PassOrder(ii)
                                    C = C + 1;
                                end
                            end
                        else if mod(PassOrder(i),SPR) == 5 % Right Middle
                                for ii = 1:i
                                    if PassOrder(i)-1 == PassOrder(ii)
                                        C = C + 1;
                                    end
                                end
                            else if mod(PassOrder(i),SPR) == 0 % Right Window
                                    for ii = 1:i
                                        if PassOrder(i)-1 == PassOrder(ii)
                                            C = C + 1;
                                        else if PassOrder(i)-2 == PassOrder(ii)
                                                C = C + 1;
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if C > 0
                        SwitchWait(i) = SwitchTime(C);
                    else
                        % inf means the time is over (i.e. it has reached 0)
                        SwitchWait(i) = inf;
                    end
                end
            else if SPR == 4 % Second case of seats per row, 4
                    for i = 1:NumPassengers
                        C = 0; % Counter for how many passengers there are for switch
                        if mod(PassOrder(i),SPR) == 1 % Left Window
                            for ii = 1:i
                                if PassOrder(i)+1 == PassOrder(ii)
                                    C = C + 1;
                                else if PassOrder(i)+2 == PassOrder(ii)
                                        C = C + 1;
                                    end
                                end
                            end
                        else if mod(PassOrder(i),SPR) == 0 % Right Window
                                for ii = 1:i
                                    if PassOrder(i)+1 == PassOrder(ii)
                                        C = C + 1;
                                    end
                                end
                            end
                        end
                        if C > 0
                            SwitchWait(i) = SwitchTime(C);
                        else
                            % inf means the time is over (i.e. it has reached 0)
                            SwitchWait(i) = inf;
                        end
                    end
                else % No switching if its not 6 or 4 SPR (Since the only other number is 2)
                    SwitchWait = ones(1,NumPassengers)*inf;
                end
            end
            if j == 5
                SwitchWait = SwitchWait*2; % Switch time is doubled for baggage holding
            end
            %
            % -------------------------------------------------------------
            
            
            
            %% Begin Experiment here
            while TotRemoved < NumPassengers
                CRow = 0; % Count of how many passengers are in the correct row
                
                
                
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                %--- Passengers moving forward and future position setting ---%
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                MaxLoc = inf;
                for i = 1:NumPassengers
                    % If statement ensures passengers are still in play (not -inf)
                    if CurPassLoc(i) ~= -inf
                        PassLoc = ceil(PassOrder(i)/SPR);
                        if PassLoc < MaxLoc
                            MaxLoc = PassLoc;
                        else
                            MaxLoc = MaxLoc - 1; % Put passenger at row before otherwise
                        end
                        % Increase walking time if the future location has changed
                        if WalkWait(i) == inf
                            WalkWait(i) = 0;
                        end
                        WalkWait(i) = WalkWait(i) + (MaxLoc - FuturePassLoc(i))*RPSec;
                        FuturePassLoc(i) = MaxLoc; % Set future location
                        if CurPassLoc(i) == ceil(PassOrder(i)/SPR)
                            CRow = CRow + 1; % Increase count by 1 if in correct row
                        end
                        % If walking wait time is 0 or less, the passenger has
                        % arrived the right row
                        if WalkWait(i) <= 0
                            WalkWait(i) = inf;
                            if CurPassLoc(i) ~= ceil(PassOrder(i)/SPR)
                                CurPassLoc(i) = FuturePassLoc(i);
                            end
                        end
                    end
                end
                
                
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                %--------------- Passengers waiting times ----------------%
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                CRowPass = zeros(2,CRow); % Passengers in the correct row
                c = 1; % Counter for inside for loop
                % Finding all passengers at their seats
                Min = inf;
                for i = 1:NumPassengers
                    % Check if minimum time is for walking
                    if Min > WalkWait(i)
                        Min = WalkWait(i);
                    end
                    if CurPassLoc(i) == ceil(PassOrder(i)/SPR)
                        % Check if minimum time is for waiting for luggage
                        if Min > PassWait(k,i)
                            Min = PassWait(k,i);
                        end
                        % Or if minimum time is for doing a 'switch'
                        if PassWait(k,i) == inf % First check that baggage has been stored
                            if Min > SwitchWait(i)
                                Min = SwitchWait(i);
                            end
                        end
                        CRowPass(1,c) = i; % Unique Passenger ID
                        CRowPass(2,c) = CurPassLoc(i); % Current Passenger Pos
                        c = c + 1;
                    end
                end
                if Min == inf
                    Min = 0;
                end
                TotTime = TotTime + Min; % Add the min time to total time
                % Adjust the wait times from the time waited
                for i = 1:NumPassengers
                    WalkWait(i) = WalkWait(i) - Min;
                end
                for i = 1:CRow
                    % Remove the time waited for passengers on their row
                    if PassWait(k,CRowPass(1,i)) <= 0 || PassWait(k,CRowPass(1,i)) == inf
                        SwitchWait(CRowPass(1,i)) = SwitchWait(CRowPass(1,i)) - Min;
                    end
                    PassWait(k,CRowPass(1,i)) = PassWait(k,CRowPass(1,i)) - Min;
                    
                    if PassWait(k,CRowPass(1,i)) <= 0
                        % Set wait time to inf so it isn't included anymore
                        PassWait(k,CRowPass(1,i)) = inf;
                    end
                    if SwitchWait(CRowPass(1,i)) <= 0
                        SwitchWait(CRowPass(1,i)) = inf;
                    end
                    % If both switch and baggage times are 0, then remove
                    % the passenger
                    if SwitchWait(CRowPass(1,i)) == inf && PassWait(k,CRowPass(1,i)) == inf
                        CurPassLoc(CRowPass(1,i)) = -inf;
                        TotRemoved = TotRemoved + 1;
                    end
                end
            end
            if j == 5 && IncludeBest == 0
                Data(j,k) = TotTime;
            else
                Data(j+1,k) = TotTime;
            end
        end
        if j == 5
            c = 0;
            if IncludeBest == 1
                c = 1;
            end
            % Add on SPR * 0-8 sec of time for loading bags
            Data(j+c,:) = Data(j+c,:) + SPR*8*rand;
        end
        if j == 5 && IncludeBest == 0
            Average(j) = mean(Data(j,:));
            Spread(j) = std(Data(j,:));
        else
            Average(j+1) = mean(Data(j+1,:));
            Spread(j+1) = std(Data(j+1,:));
        end
    end
end


%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%-------------------------------- Outputs --------------------------------%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
T = table(transpose(Names),transpose(round(Average)),transpose(round(Spread)));
T.Properties.VariableNames = {'OrderingType','Average','Spread'}

%%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%---------------------------------- Plots --------------------------------%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
t = linspace(min(Average)-max(Spread)*2,max(Average)+max(Spread)*2,10000);
hold on;
if IncludeBest == 0
    p = zeros(1,NumOrder);
    Colours = hsv(NumOrder);
    for i = 1:NumOrder
        p(i) = plot(t,normpdf(t,Average(i),Spread(i)),'Color',Colours(i,:));
    end
else
    p = zeros(1,NumOrder+1);
    Colours = hsv(NumOrder+1);
    for i = 1:NumOrder+1
        p(i) = plot(t,normpdf(t,Average(i),Spread(i)),'Color',Colours(i,:));
    end
end
xlabel('Time Taken')
ylabel('Prob Density')
title('Method prob. density assuming normal distribution')
legend(p,Names)