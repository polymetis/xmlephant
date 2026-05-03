# XMLephant

```
             <?xml version="1.0">                                              
           <phant>%%%%%%%%%%%%%%%%%>,.                                       
         .>%%%%%%%%%%%%%%%%%%>>,%%%%%%;,.                                  
       .>>>>%%%%%%%%%%%%%>>,%%%%%%%%%%%%,>>%%,.                            
     .>>%>>>>%%%%%%%%%>>,%%%%%%%%%%%%%%%%%,>>%%%%%,.                       
   .>>%%%%%>>%%%%>>,%%>>%%%%%%%%%%%%%%%%%%%%,>>%%%%%%%,                    
  .>>%%%%%%%%%%>>,%%%%%%>>%%%%%%%%%%%%%%%%%%,>>%%%%%%%%%%.                 
 .>>%%%%%%%%%%>>,>>>>%%%%%%%%%%'..`%%%%%%%%,;>>%%%%%%%%%>%%.               
.>>%%%>>>%%%%%>,%%%%%%%%%%%%%%.%%%,`%%%%%%,;>>%%%%%%%%>>>%%%%.             
>>%%>%>>>%>%%%>,%%%%%>>%%%%%%%%%%%%%`%%%%%%,>%%%%%%%>>>>%%%%%%%.           
>>%>>>%%>>>%%%%>,%>>>%%%%%%%%%%%%%%%%`%%%%%%%%%%%%%%%%%%%%%%%%%%.          
>>%%%%%%%%%%%%%%,>%%%%%%%%%%%%%%%%%%%'%%%,>>%%%%%%%%%%%%%%%%%%%%%.         
>>%%%%%%%%%%%%%%%,>%%%>>>%%%%%%%%%%%%%%%,>>%%%%%%%%>>>>%%%%%%%%%%%.        
>>%%%%%%%%;%;%;%%;,%>>>>%%%%%%%%%%%%%%%,>>>%%%%%%>>;";>>%%%%%%%%%%%%.      
`>%%%%%%%%%;%;;;%;%,>%%%%%%%%%>>%%%%%%%%,>>>%%%%%%%%%%%%%%%%%%%%%%%%%%.    
 >>%%%%%%%%%,;;;;;%%>,%%%%%%%%>>>>%%%%%%%%,>>%%%%%%%%%%%%%%%%%%%%%%%%%%%.  
 `>>%%%%%%%%%,%;;;;%%%>,%%%%%%%%>>>>%%%%%%%%,>%%%%%%'%%%%%%%%%%%%%%%%%%%>>.
  `>>%%%%%%%%%%>,;;%%%%%>>,%%%%%%%%>>%%%%%%';;;>%%%%%,`%%%%%%%%%%%%%%%>>%%>.
   >>>%%%%%%%%%%>> %%%%%%%%>>,%%%%>>>%%%%%';;;;;;>>,%%%,`%     `;>%%%%%%>>%%
   `>>%%%%%%%%%%>> %%%%%%%%%>>>>>>>>;;;;'.;;;;;>>%%'  `%%'          ;>%%%%%>
    >>%%%%%%%%%>>; %%%%%%%%>>;;;;;;''    ;;;;;>>%%%                   ;>%%%%
    `>>%%%%%%%>>>, %%%%%%%%%>>;;'        ;;;;>>%%%'                    ;>%%%
     >>%%%%%%>>>':.%%%%%%%%%%>>;        .;;;>>%%%%                    ;>%%%'
     `>>%%%%%>>> ::`%%%%%%%%%%>>;.      ;;;>>%%%%'                   ;>%%%' 
      `>>%%%%>>> `:::`%%%%%%%%%%>;.     ;;>>%%%%%                   ;>%%'  
       `>>%%%%>>, `::::`%%%%%%%%%%>,   .;>>%%%%%'                   ;>%'   
        `>>%%%%>>, `:::::`%%%%%%%%%>>. ;;>%%%%%%                    ;>%,   
         `>>%%%%>>, :::::::`>>>%%%%>>> ;;>%%%%%'                     ;>%,  
          `>>%%%%>>,::::::,>>>>>>>>>>' ;;>%%%%%                       ;%%, 
            >>%%%%>>,:::,%%>>>>>>>>'   ;>%%%%%.                        ;%% 
             >>%%%%>>``%%%%%>>>>>'     `>%%%%%%.                           
             >>%%%%>> `@@a%%%%%%'     .%%%%%%%%%.                          
             `a@@a%@'    `%a@@'       `a@@a%</phant>
             
```
Ascii art by [Susie Oviatt](http://www.roysac.com/tutorial/susieasciiarttutorial.html) -placeholder link until I can find her in particular rather than just her work. 

## What it does

XMLephant is a [Postgrex](https://hexdocs.pm/postgrex) extension for the PostgreSQL `xml` column type. With it installed, `xml` columns round-trip through Postgrex as plain Elixir binaries — you can pass an XML string as a query parameter and `SELECT xml` hands the binary back.

## Installation

Add `xmlephant` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xmlephant, "~> 0.1.0"}
  ]
end
```

## Usage

Define a Postgrex types module that includes the extension. For raw Postgrex:

```elixir
# lib/my_app/postgrex_types.ex
Postgrex.Types.define(MyApp.PostgrexTypes, [Xmlephant.Extension])
```

For Ecto, mix in the adapter's defaults:

```elixir
Postgrex.Types.define(
  MyApp.PostgrexTypes,
  [Xmlephant.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)
```

Then point Postgrex (or Ecto) at the types module:

```elixir
# Postgrex
{:ok, pid} = Postgrex.start_link(types: MyApp.PostgrexTypes, ...)

# Ecto
config :my_app, MyApp.Repo, types: MyApp.PostgrexTypes
```

`xml` columns now behave like binaries:

```elixir
{:ok, _} = Postgrex.query(pid, "INSERT INTO docs (xml) VALUES ($1)", ["<root>hello</root>"])
{:ok, %Postgrex.Result{rows: [["<root>hello</root>"]]}} =
  Postgrex.query(pid, "SELECT xml FROM docs", [])
```

PostgreSQL validates well-formedness on insert; malformed XML is rejected with `:invalid_xml_content`.

## Options

- `:decode_copy` — `:copy` (default) or `:reference`. Controls whether decoded values are copied off the receive buffer. `:reference` avoids the copy when you'll process the value before the connection's next message; otherwise stick with the default.

## A note on untrusted XML

This library is a byte passthrough — it does not parse XML in Elixir. PostgreSQL parses on insert (well-formedness only) and again whenever you call `xpath`, `XMLTABLE`, or `xmlexists`. libxml2 expands internal entities, so running XPath or XMLTABLE against attacker-controlled XML is a billion-laughs DoS vector. Treat untrusted XML the way you would in any other Postgres deployment.

## Documentation

Full docs at [hexdocs.pm/xmlephant](https://hexdocs.pm/xmlephant).

