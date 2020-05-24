function value = parseInputVar(parameter, defaultValue, varargin)
    % a function to parse varargins 

  location = find(strcmpi(varargin, parameter));
  if ~isempty(location)
      value = varargin{location(1)+1}; %Get the value after the param name
  else
      value = defaultValue;
  end
end