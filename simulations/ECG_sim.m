function ECG = ECG_sim(t, HR, varargin)
%ECG_SIM Simulate an electrocardiogram (ECG) signal with customizable parameters
%   ECG = ECG_SIM(t, HR) simulates an ECG signal with default parameter values,
%   where t is the time vector and HR is the heart rate in beats per minute.
%
%   ECG = ECG_SIM(t, HR, 'Name',Value) allows for customization of the ECG
%   signal by specifying parameter-value pairs. Valid parameter names and
%   their default values are:
%
%       Parameter Name     Default Value
%       --------------------------------------------------
%       a_pwav             0.25
%       d_pwav             0.09
%       t_pwav             0.16
%       a_qwav             0.025
%       d_qwav             0.066
%       t_qwav             0.166
%       a_qrswav           1.6
%       d_qrswav           0.11
%       a_swav             0.25
%       d_swav             0.066
%       t_swav             0.09
%       a_twav             0.35
%       d_twav             0.142
%       t_twav             0.2
%       a_uwav             0.035
%       d_uwav             0.0476
%       t_uwav             0.433
%
%   Example usage:
%       t = linspace(0, 10, 1000);
%       ECG = ECG_sim(t, 60, 'a_pwav', 0.2, 'd_pwav', 0.1);
%
%   CITATION:
%   karthik raviprakash (2023). ECG simulation using MATLAB
%   (https://www.mathworks.com/matlabcentral/fileexchange/10858-ecg-simulation-using-matlab),
%   MATLAB Central File Exchange. Retrieved March 6, 2023.

%Simulate data
if nargin == 0
    T = 20;
    Fs = 125;
    t=linspace(0,T,Fs*T);
end

if nargin<2
    HR = 60;
end

li=30/HR;

% Create input parser
p = inputParser;

% Add parameter-value pairs with default values
addParameter(p, 'a_pwav', 0.25);
addParameter(p, 'd_pwav', 0.09);
addParameter(p, 't_pwav', 0.16);
addParameter(p, 'a_qwav', 0.025);
addParameter(p, 'd_qwav', 0.066);
addParameter(p, 't_qwav', 0.166);
addParameter(p, 'a_qrswav', 1.6);
addParameter(p, 'd_qrswav', 0.11);
addParameter(p, 'a_swav', 0.25);
addParameter(p, 'd_swav', 0.066);
addParameter(p, 't_swav', 0.09);
addParameter(p, 'a_twav', 0.35);
addParameter(p, 'd_twav', 0.142);
addParameter(p, 't_twav', 0.2);
addParameter(p, 'a_uwav', 0.035);
addParameter(p, 'd_uwav', 0.0476);
addParameter(p, 't_uwav', 0.433);

% Parse inputs
parse(p, varargin{:});

% Assign parsed input arguments to variables
a_pwav = p.Results.a_pwav;
d_pwav = p.Results.d_pwav;
t_pwav = p.Results.t_pwav;
a_qwav = p.Results.a_qwav;
d_qwav = p.Results.d_qwav;
t_qwav = p.Results.t_qwav;
a_qrswav = p.Results.a_qrswav;
d_qrswav = p.Results.d_qrswav;
a_swav = p.Results.a_swav;
d_swav = p.Results.d_swav;
t_swav = p.Results.t_swav;
a_twav = p.Results.a_twav;
d_twav = p.Results.d_twav;
t_twav = p.Results.t_twav;
a_uwav = p.Results.a_uwav;
d_uwav = p.Results.d_uwav;
t_uwav = p.Results.t_uwav;

%p_wave output
pwav=p_wav(t,a_pwav,d_pwav,t_pwav,li);

%qwav output
qwav=q_wav(t,a_qwav,d_qwav,t_qwav,li);

%qrswav output
qrswav=qrs_wav(t,a_qrswav,d_qrswav,li);

%swav output
swav=s_wav(t,a_swav,d_swav,t_swav,li);

%twav output
twav=t_wav(t,a_twav,d_twav,t_twav,li);

%uwav output
uwav=u_wav(t,a_uwav,d_uwav,t_uwav,li);

%ecg output
ECG=pwav+qrswav+twav+swav+qwav+uwav;
end

function [pwav]=p_wav(x,a_pwav,d_pwav,t_pwav,li)
a=a_pwav;
x=x+t_pwav;
b=(2*li)/d_pwav;
n=50;
p1=1/li;

harms = transpose(1:n);

harm1=(((sin((pi./(2*b)).*(b-(2.*harms))))./(b-(2.*harms))+(sin((pi./(2.*b)).*(b+(2.*harms))))./(b+(2.*harms))).*(2/pi)).*cos((harms.*pi.*x)./li);
p2 = sum(harm1);

pwav1=p1+p2;
pwav=a*pwav1;
end

function [qwav]=q_wav(x,a_qwav,d_qwav,t_qwav,li)
x=x+t_qwav;
a=a_qwav;
b=(2*li)/d_qwav;
n=50;
q1=(a/(2*b))*(2-b);

harms = transpose(1:n);

harm5=(((2*b*a)./(harms.*harms.*pi*pi)).*(1-cos((harms*pi)/b))).*cos((harms*pi*x)/li);
q2=sum(harm5);

qwav=-1*(q1+q2);
end

function [qrswav]=qrs_wav(x,a_qrswav,d_qrswav,li)
a=a_qrswav;
b=(2*li)/d_qrswav;
n=50;
qrs1=(a/(2*b))*(2-b);

harms = transpose(1:n);
harm=(((2*b*a)./(harms.*harms*pi*pi)).*(1-cos((harms*pi)/b))).*cos((harms.*pi.*x)/li);
qrs2=sum(harm);

qrswav=qrs1+qrs2;
end

function [swav]=s_wav(x,a_swav,d_swav,t_swav,li)
x=x-t_swav;
a=a_swav;
b=(2*li)/d_swav;
n=50;
s1=(a/(2*b))*(2-b);

harms = transpose(1:n);

harm3=(((2*b*a)./(harms.*harms*pi*pi)).*(1-cos((harms.*pi)/b))).*cos((harms.*pi.*x)/li);
s2=sum(harm3);

swav=-1*(s1+s2);
end

function [twav]=t_wav(x,a_twav,d_twav,t_twav,li)

a=a_twav;
x=x-t_twav-0.045;
b=(2*li)/d_twav;
n=50;
t1=1/li;

harms = transpose(1:n);
harm2=(((sin((pi/(2*b)).*(b-(2*harms))))./(b-(2*harms))+(sin((pi/(2*b)).*(b+(2*harms))))./(b+(2.*harms))).*(2/pi)).*cos((harms.*pi.*x)/li);
t2=sum(harm2);

twav1=t1+t2;
twav=a*twav1;
end

function [uwav]=u_wav(x,a_uwav,d_uwav,t_uwav,li)

a=a_uwav;
x=x-t_uwav;
b=(2*li)/d_uwav;
n=50;
u1=1/li;

harms = transpose(1:n);
harm4=(((sin((pi/(2*b)).*(b-(2*harms))))./(b-(2*harms))+(sin((pi/(2*b)).*(b+(2*harms))))./(b+(2*harms))).*(2/pi)).*cos((harms.*pi.*x)/li);
u2=sum(harm4);

uwav1=u1+u2;
uwav=a*uwav1;
end