filename = '';
load(filename, 'logs');

x = [
90
100
600
900
1200
1500
1800];  % number of simulations

y = [
0.6333139156
0.7661558584
0.9890769401
0.9799218352
0.9653440637
0.9852706486
0.9921305628];  % confidence
yyaxis left
xq1 = min(x):1:max(x);
y1 = interp1(x, y, xq1, 'pchip');
plot(x,y, 'o', xq1, y1, ':.');



% minimum robustness
yyaxis right

xr = min(x):max(x);
yr = [];
for i = xr
    yr = [yr min(logs.obj_log(1:i))];
end

%r1 = interp1(x, r, xq1, 'previous');
plot(xr, yr);

yyaxis left
title('Confidence Change', 'FontName', 'times', 'FontSize', 30)
xlabel('number of simulations','FontSize', 25)
ylabel('Confidence', 'FontSize', 25)

yyaxis right
ylabel('Minimum robustness', 'FontSize', 25)
