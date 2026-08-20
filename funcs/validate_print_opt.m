function validate_print_opt(print_opt)
%VALIDATE_PRINT_OPT print_opt must be "" (not supplied) or "none".
if print_opt ~= "" && print_opt ~= "none"
    error("you can only disable printing with none")
end
end