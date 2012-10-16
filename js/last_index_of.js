if (!Array.prototype.lastIndexOf)
{
  Array.prototype.lastIndexOf = function(searchElement /*, fromIndex*/)
  {
    "use strict";
 
    if (this == null)
      throw new TypeError();
 
    var t = Object(this);
    var len = t.length >>> 0;
    if (len === 0)
      return -1;
 
    var n = len;
    if (arguments.length > 1)
    {
      n = Number(arguments[1]);
      if (n != n)
        n = 0;
      else if (n != 0 && n != (1 / 0) && n != -(1 / 0))
        n = (n > 0 || -1) * Math.floor(Math.abs(n));
    }
 
    var k = n >= 0
          ? Math.min(n, len - 1)
          : len - Math.abs(n);
 
    for (; k >= 0; k--)
    {
      if (k in t && t[k] === searchElement)
        return k;
    }
    return -1;
  };
}