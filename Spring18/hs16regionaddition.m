function hs16regionaddition
% 
% Here we compare the sums of individual Ice Mass Trend Estimates for some
% regions to the Ice Mass Trend Estimate for the union of those regions.
% NOTE: We assume that the regions do NOT overlap/intersect.
% NOTE: Currently my results are silly.  I need to deal with unit conversion
% to be in Gt, because I think I'm in tons right now, and I need to make
% sure it's /m^2 etc.  First I need to get rid of bad data though so that
% I can recognize once I get it working that it is indeed working.
% 
% Authored by maxvonhippel-at-email.arizona.edu on 01/20/18

defval('regionA','iceland');
defval('regionB','greenland');
defval('L',60);
defval('b',0.5);
defval('res',10);

[fullS,~,thedates]=grace2plmt('CSR','RL05','SD',0);
fullS=fullS(:,:,1:4);
nmonths=length(thedates);

% Seperate regions
[slepcoffsA,~,~,THA,GA,CCA,~,~]=grace2slept('CSRRL05',regionA,...
  b,L,[],[],[],[],'SD',1);
[slepcoffsB,~,~,THB,GB,CCB,~,~]=grace2slept('CSRRL05',regionB,...
  b,L,[],[],[],[],'SD',1);

% Aggregate region
regionAgg=[eval(sprintf('%s(%i,%f)',regionA,res,b));
           NaN NaN;
           eval(sprintf('%s(%i,%f)',regionB,res,b))];
[slepcoffsAgg,~,~,THAgg,GAgg,CCAgg,~,~]=grace2slept('CSRRL05',regionAgg,...
  b,L,[],[],[],[],'SD',1);

% Recover trends
[~,~,~,lmcosipad,~,~,~,~,~,ronm]=addmon(L);
sleptA=zeros(nmonths,(L+1)^2);
sleptB=zeros(nmonths,(L+1)^2);
sleptAgg=zeros(nmonths,(L+1)^2);

for k=1:nmonths
  lmcosi=squeeze(fullS(k,:,:));
  if size(lmcosi,1) < addmup(L)
    lmcosi=[lmcosi; lmcosipad(size(lmcosi,1)+1:end,:)];
  else
    lmcosi=lmcosi(1:addmup(L),:);
  end
  sleptA(k,:)=GA'*lmcosi(2*size(lmcosi,1)+ronm(1:(L+1)^2));
  sleptB(k,:)=GB'*lmcosi(2*size(lmcosi,1)+ronm(1:(L+1)^2));
  % Aggregate
  sleptAgg(k,:)=GAgg'*lmcosi(2*size(lmcosi,1)+ronm(1:(L+1)^2));
end

% Estimate the total mass changes
[~,~,~,~,~,~,totalparamsA,~,~,~,~]=slept2resid(sleptA,thedates,[1 365.0],...
  [],[],CCA,THA);
[~,~,~,~,~,~,totalparamsB,~,~,~,~]=slept2resid(sleptB,thedates,[1 365.0],...
  [],[],CCB,THB);
regionAtrend=totalparamsA(2)*365;
regionBtrend=totalparamsB(2)*365;
regionABtrend=regionAtrend+regionBtrend;

% Estimate the aggregate mass change
[~,~,~,~,~,~,totalparamsAgg,~,~,~,~]=slept2resid(sleptAgg,thedates,[1 365.0],...
  [],[],CCAgg,THAgg);
regionAggtrend=totalparamsAgg(2)*365;

regionDiff=regionABtrend-regionAggtrend;

% Print messages
format long g
% Print messages
format long g
disp(sprintf('Shannon Number, Region, Trend\n%f, %s, %f',...
  round((L+1)^2*spharea(regionA)),regionA,regionAtrend));
disp(sprintf('%f, %s, %f',...
  round((L+1)^2*spharea(regionB)),regionB,regionBtrend));
disp(sprintf('(Sum of trends: %f)',regionABtrend));
disp(sprintf('%f, Combined Region, %f',...
  round((L+1)^2*spharea(regionAgg)),regionAtrend));
disp(sprintf('(Difference: Sum of trends - Combined trend = %f\n)',...
  regionDiff));