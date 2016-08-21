function print_cpu_indep(plotpath, cpu);
if cpu 
        print([plotpath '.jpg'], '-djpg')
else
        printplt(plotpath)
endif
endfunction
