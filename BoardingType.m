% Boarding type helper function for AirplaneBoarding.m
% 
% Made by Markus Martin
% November 2019

function BoardVec = BoardingType(Passengers,SPR,Type)
% The BoardingType function takes an input of the number of seats that are
% available, the seats per row and the Type number and gives a vector
% containing the boarding order of the passengers.
% The following are the different types of boarding:
% 0 - Randomized boarding order
% 1 - Worst boarding order (low numbers first)
% 2 - Boarding from high numbers first (descending order)
% 3 - Odd right -> Odd left -> Even right -> Even left
% 4 - Best boarding order (groups of passengers with 1 for each row)
Order = zeros(1,Passengers);
Rows = ceil(Passengers/SPR);
switch Type
    case 0
        Order = 1:Passengers;
        Order = Order(randperm(Passengers));
    case 1
        Order = 1:Passengers;
    case 2
        Order = linspace(Passengers,1,Passengers);
    case 3
        NumPerGroup = floor(Passengers/4); % Number passengers per group
        SPS = SPR/2; % Seats per side
        Group = zeros(4,NumPerGroup);
        % Define what's in each group
        for i = 1:NumPerGroup/SPS
            Group(1,SPS*(i-1)+1:SPS*i) = linspace(SPS+1,2*SPS,SPS) + 2*SPR*(i-1);
            Group(2,SPS*(i-1)+1:SPS*i) = linspace(1,SPS,SPS) + 2*SPR*(i-1);
            Group(3,SPS*(i-1)+1:SPS*i) = linspace(3*SPS+1,4*SPS,SPS) + 2*SPR*(i-1);
            Group(4,SPS*(i-1)+1:SPS*i) = linspace(2*SPS+1,3*SPS,SPS) + 2*SPR*(i-1);
        end
        for i = 1:4
            % Randomise the group
            Group(i,:) = Group(i,randperm(NumPerGroup));
            % Put the groups into the correct order
            Order(NumPerGroup*(i-1)+1:NumPerGroup*i) = Group(i,:);
        end
    case 4
        for k = 1:SPR
            Order(((k-1)*Rows+1):k*Rows) = linspace(Passengers+1-k,SPR+1-k,Rows);
        end
end

BoardVec = Order;
end