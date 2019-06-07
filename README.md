Tabular
=======

Tabular is a reader for data in ascii table format.
It allows you to read string data formatted like this:

<pre>
|------------------+--------------------|
| name             | dob                |
|------------------+--------------------|
| Malcolm Reynolds | September 20, 2468 |
|------------------+--------------------|
| Zoe Washburne    | February 15, 2484  |
|------------------+--------------------|
</pre>

In [Ascii Tables For Clearer Testing][1] I discuss using ascii tables to improve comprehension
of software tests.

[1]: https://punctuatedproductivity.wordpress.com/2016/02/02/ascii-tables-for-clearer-testing/

Installation
------------

The package can be installed by adding `tabular` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tabular, "~> 0.1.0"}
  ]
end
```

Usage
-----

Rows are returned as either lists of lists or lists of maps.

<pre>
|-----------------------+------------------------------+-----------------------------------|
| **Ascii Table Value** | **Returned Value**           | **Notes**                         |
|-----------------------+------------------------------+-----------------------------------|
| Malcolm Reynolds      | "Malcolm Reynolds"           | Most values returned as string    |
|-----------------------+------------------------------+-----------------------------------|
| 123                   | "123"                        | including numbers                 |
|-----------------------+------------------------------+-----------------------------------|
| wrapped strings are   | "wrapped strings are folded" | Similar to yaml, wrapped          |
| folded                |                              | strings are folded with a single  |
|                       |                              | space replacing the new line      |
|-----------------------+------------------------------+-----------------------------------|
|                       | nil                          | nil is returned for blank values  |
|-----------------------+------------------------------+-----------------------------------|
| nil                   | nil                          | nil, true, and false are          |
|                       |                              | special values                    |
|-----------------------+------------------------------+-----------------------------------|
| true                  | true                         |                                   |
|-----------------------+------------------------------+-----------------------------------|
| false                 | false                        |                                   |
|-----------------------+------------------------------+-----------------------------------|
| :foo                  | :foo                         | Values starting with a colon are  |
|                       |                              | returned as atoms                 |
|-----------------------+------------------------------+-----------------------------------|
</pre>

**Reading a String**

```elixir
  Tabular.to_list_of_lists_no_header(table)
  |> Enum.each(fn [col1, col2, col3] = row ->
    # use row or column data here...
  end
```

More examples can be found in the Examples of Testing With ASCII Tables [repo](https://github.com/kellyfelkins/examples_of_testing_with_ascii_tables).

The docs can be found at [https://hexdocs.pm/tabular](https://hexdocs.pm/tabular).

## License

Blue Oak Model license. Please see [LICENSE][license] for details.

[LICENSE]: https://github.com/kellyfelkins/tabular/blob/master/LICENSE.md
