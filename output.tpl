 %{for index, k in dns }   
  ${index+1} ${k}   ${ip[index]}    ${password[index]}    
   %{endfor }             
                         
 