function Table2Latex(T)
    %Creates a latex format for an input table
    for i = 1:length(T)
        fprintf("%s ", T);
        fprintf("& ");
    end

end