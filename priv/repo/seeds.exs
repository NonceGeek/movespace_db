# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ChatProgramming.Repo.insert!(%ChatProgramming.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ChatProgramming.{Space, Card, Expert}

{:ok, space_sui} =
  Space.create(%{
    name: "sui",
    description:
      "Sui is a boundless platform to build rich and dynamic on-chain assets from gaming to finance."
  })

{:ok, space_aptos} =
  Space.create(%{
    name: "aptos",
    description:
      "Committed to developing products and applications on the Aptos blockchain that redefine the web3 user experience."
  })

Card.create(%{
  title: "Sui 极速上手 | Move dApp 极速入门（拾贰）",
  url: "https://mp.weixin.qq.com/s/jrz3p9x495HpAvQEYRNiZw",
  context: "let's move on Sui!",
  space_id: space_sui.id
})

Card.create(%{
  title: "Aptos CLI使用指南与REPL设计建议 | Move dApp 极速入门（六）",
  url: "https://mp.weixin.qq.com/s/2_0wL1KIAdoxYqya-thi6Q",
  context: "本文一方面是 Aptos 的 CLI 工具操作指南，另一方面会延伸来讲讲笔者关于 CLI/REPL 工具设计的一些看法。",
  space_id: space_aptos.id
})

Expert.create(%{
  name: "leeduckgo",
  description: "Cool-oriented Programming.",
  url: "https://noncegeek.com",
  avatar: "todo",
  space_id: space_aptos.id,
})

Expert.create(%{
  name: "yekai",
  description: "Blockchain Expert.",
  url: "https://noncegeek.com",
  avatar: "todo",
  space_id: space_sui.id,
})
