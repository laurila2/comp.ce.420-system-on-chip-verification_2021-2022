//------------------------------------------------------------
//   Copyright 2007-2009 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//   
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//   
//       http://www.apache.org/licenses/LICENSE-2.0
//   
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------

class my_report_server extends uvm_report_server;
  int name_width = 20;
  int id_width   = 20;

  function string pad(string s, int width);
    string r;
  
    if ( s.len() == width ) 
      return s;
  
    if ( s.len() < width ) begin
      // s is short. Pad at the end.
      r = s;
      for(int i = s.len(); i < width; i++)
        r = {r, " "}; 
      return r;
    end
    else 
      // s is too long. truncate.
      //return s.substr(0, width-1);
      return s.substr(s.len()-width, s.len()-1);
  endfunction

  function string compose_message(
     uvm_severity severity,
      string name,
      string id,
      string message,
      string filename,
      int    line
    );
     // Don't want these being long.
     name = pad(name, name_width); 
     id   = pad(id,     id_width); 

     return super.compose_message(
         severity, name, id, message, filename, line);
  endfunction
endclass
