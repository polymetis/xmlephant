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
Ascii art by [Susie Oviatt](https://text-mode.org/?p=24923); tutorial preserved at [roysac.com](http://www.roysac.com/tutorial/susieasciiarttutorial.html).

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

- `:decode_binary` — `:copy` (default) or `:reference`. With `:reference` the decoded value is a sub-binary pointing into Postgrex's receive buffer, and that buffer is reused on the next message — retaining the value across messages (storing it in process state, putting it in ETS, sending it to another process) without first calling `:binary.copy/1` reads garbage or crashes the VM. Default to `:copy`; only choose `:reference` when you've measured a copy bottleneck and you fully consume the value inside the same checkout. Same name and semantics as Postgrex's built-in binary extension.

## A note on untrusted XML

This library is a byte passthrough — it does not parse XML in Elixir. PostgreSQL parses on insert (well-formedness only) and again whenever you call `xpath`, `XMLTABLE`, or `xmlexists`. libxml2 expands internal entities, so running XPath or XMLTABLE against attacker-controlled XML is a billion-laughs DoS vector. Postgres exposes no knob to disable entity expansion; if you handle untrusted XML, sanitize or pre-parse it in your application before insert, and wrap server-side `xpath`/`XMLTABLE`/`xmlexists` calls in a `statement_timeout` so a malicious `<lol9>` payload cannot hold a backend hostage.

## Running the tests

The suite hits a real PostgreSQL. Defaults assume `postgres`/`postgres` on `localhost:5432` and a database called `xmlephant_test`; override any of them with environment variables.

```sh
bin/test_database_setup   # creates the test database
mix test
```

Recognised env vars (with defaults): `PG_HOSTNAME` (`localhost`), `PG_USERNAME` (`postgres`), `PG_PASSWORD` (`postgres`), `PG_DATABASE` (`xmlephant_test`).

## Documentation

Full docs at [hexdocs.pm/xmlephant](https://hexdocs.pm/xmlephant).

