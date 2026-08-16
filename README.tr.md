# DeepSeek Harness

[English](README.md) | [中文](README.zh.md) | Türkçe

DeepSeek Harness (`dsh`), [DeepSeek AI](https://deepseek.com) tarafından geliştirilen açık kaynaklı bir agent harness'tır (ajan çatısı).

**Her şey bir plugin'dir** mimarisini kullanır ve tasarımı [_A Programming Paradigm for Spatiotemporal Composability_](https://github.com/cordiverse/paper) makalesinde anlatılan [Cordis](https://github.com/cordiverse/cordis) tarafından güçlendirilir.

## Geliştirici önizlemesi

DeepSeek Harness şu anda _geliştirici önizlemesi_ aşamasındadır ve hızla gelişmektedir. **UYUMLULUĞU BOZAN DEĞİŞİKLİKLER OLACAKTIR.**

## Çalıştırma

### `npm` üzerinden çalıştırma

`Node.js`'i kur, ardından çalıştır:

```sh
npx @deepseek-ai/dsh web
```

Bu komut, varsayılan olarak `http://127.0.0.1:3080` adresinde yayına giren Web UI'yi başlatır. Bkz. [Web UI kılavuzu](docs/user/guide/index.md).

### Kaynaktan çalıştırma

Bir repository checkout'undan çalıştırmak için:

```sh
git clone https://github.com/deepseek-ai/deepseek-harness.git
cd deepseek-harness
pnpm install
pnpm run build
pnpm dsh web
```

## Topluluk ve destek

- Geri bildirim veya hata raporlarını [GitHub Discussions](https://github.com/deepseek-ai/deepseek-harness/discussions) üzerinden iletebilirsin.
- Plugin repository'ni keşfedilebilir kılmak için [`dsh-plugin`](https://github.com/topics/dsh-plugin) topic'ini ekle.
- <a href="https://discord.gg/Ycq5dCaS4">DeepSeek Harness Discord topluluğuna</a> katıl.

## Katkıda bulunma

Bkz. [CONTRIBUTING.md](CONTRIBUTING.md).

## Geliştirme

[Geliştirme kılavuzu](docs/development.md) ve [mimari dokümantasyonu](docs/architecture.md) ile başla.

Ajanlar için: [AGENTS.md](AGENTS.md)'yi takip et.

## DSH destekli inceleme otomasyonu

Bu fork, `dsh`'yi hem talep üzerine hem de CI içinde otomatik bir ikinci görüş olarak da çalıştırır. Elle danışmak için, repository kökünden `dsh --profile headless "<soru>"` çalıştır ve kodu doğrudan prompt'a gömerek gönder — `dsh` çağrılar arasında hiçbir hafıza tutmaz. `pull_request` olaylarında otomatik bir inceleme yorumu bırakır; yeni açılan issue'larda ise bu repository'nin gerçek etiket listesiyle süzülmüş etiketler önerir ve uygular; her iki yoldaki her hata da akışı engellemez, sadece ne olduğunu bildirir. İkisini de etkinleştirmek için Settings → Secrets and variables → Actions altında `OLLAMA_API_KEY` secret'ını (ve isteğe bağlı olarak `DSH_MODEL_ID`, `DSH_ALLOWED_LABELS` repository değişkenlerini) ayarla. Tam kurulum, prompt kuralları ve sorun giderme [`dsh-integration` skill'inde](.agents/skills/dsh-integration/SKILL.md) yer alır.

## Lisans

[MIT](LICENSE)

Üçüncü taraf bağımlılıklar ve lisansları [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) dosyasında açıklanmıştır.
