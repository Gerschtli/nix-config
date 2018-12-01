{ lib }:

path:

{
  environment = {
    etc = builtins.listToAttrs
      (map
        (file:
          let filePath = "${path}/${file}"; in
          lib.nameValuePair
            filePath
            { source = ../files + "/${filePath}"; }
        )
        ["index.html" "robots.txt"]
      );
  };

  root = "/etc/${path}";
}
