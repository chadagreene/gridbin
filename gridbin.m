function [vq,N] = gridbin(x,y,z,xq,yq,func) 
% gridbin is a fast way to bin lots of scattered data into a gridded format. 
% This function is similar to griddata with the nearest-neighbor option,
% except that gridbin only produces finite values in grid cells that
% contain finite scattered measurements. This function uses accumarray to
% calculate the mean (or other statistics) of all scattered data within
% each grid cell. 
% 
%% Syntax
% 
%  vq = gridbin(x,y,v,xq,yq) 
%  vq = gridbin(...,@func) 
%  [vq,N] = gridbin(...) 
% 
%% Description
% 
% vq = gridbin(x,y,v,xq,yq) produces a 2D grid of values vq at the coordinates 
% xq,yq. Inputs x,y,v may be scattered data, and the output vq is the mean
% of all scattered values v within each spatial bin. 
% 
% vq = gridbin(...,@func) applies any function @func to the v data. By
% default, @func is @mean, meaning that vq contains the mean of all values
% v within each spatial bin. 
% 
% [vq,N] = gridbin(...) also returns a grid N containing the number of
% observations v in each bin. 
%
%% Example 
% For examples, type 
% 
%  showdemo gridbin_documentation 
% 
%% Author Info
% Written by Chad A. Greene of NASA/JPL August 2021. 
% 
% See also griddata, histogram2, discretize, and accumarray. 

%% Input checks: 

narginchk(5,6) 
if nargin>5
	assert(isa(func,'function_handle'),'Error: Input func must be a function handle beginning with the @ symbol, e.g., @median.')
else
   func = @mean; % default
end

assert(isequal(size(x),size(y),size(z)),'Error: Dimensions of x,y,z must all agree.')
   
%% Operate on data: 

clz = class(z); 
if ismember(clz,{'single','double'})
   FillVal = NaN; 
else
   FillVal = zeros(1,clz); 
end

if ~isvector(xq) 
   % assume xq,yq were created by [xq,yq] = meshgrid(xq_array,yq_array); 
   xq = xq(1,:); 
   yq = yq(:,1); 
end

% Resolution in each direction: 
resx = diff(xq(1:2)); 
resy = diff(yq(1:2)); 

% Discard NaNs and anything outside the grid domain: 
isn = isnan(z) | x<min(xq) | y<min(yq) | x>max(xq) | y>max(yq) ;
x(isn) = []; 
y(isn) = []; 
z(isn) = []; 

x = x - xq(1) + resx/2; % adding resx/2 centers coordinates x at the center of pixels. 
y = y - yq(1) + resy/2; 

vq = accumarray(floor([y/resy x/resx])+1,z,[length(yq) length(xq)],func,FillVal);

% Number of observations: 
if nargout==2
   N = accumarray(floor([y/resy x/resx])+1,ones(size(z)),[length(yq) length(xq)],@sum);
end

end


