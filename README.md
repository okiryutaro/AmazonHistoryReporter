# AmazonHistoryReporter

「RubyではじめるWebアプリの作り方  久保秋 真」を勉強しました。

account.jsonに、自分のamazonアカウントに登録したメールアドレスとパスワードを打ち込んでください。
コマンドプロンプトで「order_history_reporter.rb -a account.json > record.output」と入力し、エンターを押してください。
record.outputに自分の注文履歴が出てきます。

コマンドラインオプションもあります。
-t で　注文履歴を取得する期間を指定できます。
指定の種類は、last(過去30日間)、month(過去3か月間)、arc(非表示にした注文)、年度の4つです。
