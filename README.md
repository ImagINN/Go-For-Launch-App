
# Go For Launch

Go For Launch uygulamasında The Space Devs API'si kullanarak gelecek, geçmiş ve tüm fırlatmalar listelenmektedir.

## Ekran Görüntüleri

https://github.com/user-attachments/assets/c54e5b26-c8f4-4b04-9532-213ffbed3741
  

https://github.com/user-attachments/assets/2d49bb10-d977-458a-a23d-1568a6b3ae80


## Özellikler

- Gelecek, geçmiş ve tüm fırlatmaların sektörlere ayrılarak listelenmesi
- Fırlatmaların favorilere eklenmesi
- Fırlatmaların isimlerine göre arama yapılabilmesi
- Listeleme ekranında fırlatmanın gösterildiği bilgiler: Küçük resim, fırlatmanın ismi, tarih, durumu ve durum açıklaması.
- Fırlatmanın detayında gösterilen bilgiler: Büyük resim, fırlatmna başlığı, durum ve durum açıklaması ,eğer gelecek fırlatma ise geri sayım, fırlatma tarihi, fırlatmayı yapan şirketin bilgileri, roket hakkında bilgiler, görev hakkında bilgi, program hakkında bilgi.

## API Kullanımı

#### Tüm fırlatmaları getir

```http
  GET ll.thespacedevs.com/2.3.0/launches/?limit=10&mode=list
```

| Parametre | Tip     | Açıklama                |
| :-------- | :------- | :------------------------- |
| `limit` | `integer` | Bir çağrıda kaç fırlatma çekmek istediğiniz sayı. |
| `mode` | `string` | **list** gelecek verinin içeriğinin listeleme için kısa bilgiler içermesi. |

#### {id} değerine göre fırlatma getir

```http
  GET ll.thespacedevs.com/2.3.0/launches/${id}/
```

| Parametre | Tip     | Açıklama                |
| :-------- | :------- | :------------------------- |
| `id` | `uuid` | Fırlatmanın id değeri. |

#### Geçmiş fırlatmaları getir

```http
  GET ll.thespacedevs.com/2.3.0/launches/previous/?limit=10&mode=detailed
```

| Parametre | Tip     | Açıklama                |
| :-------- | :------- | :------------------------- |
| `limit` | `integer` | Bir çağrıda kaç fırlatma çekmek istediğiniz sayı. |
| `mode` | `string` | **detailed** gelecek verinin içeriğinin tüm detayını içeren bilgilerinin gelmesi için. |

#### Gelecek fırlatmaları getir

```http
  GET ll.thespacedevs.com/2.3.0/launches/upcoming/?limit=10&mode=list&offset=10
```

| Parametre | Tip     | Açıklama                |
| :-------- | :------- | :------------------------- |
| `limit` | `integer` | Bir çağrıda kaç fırlatma çekmek istediğiniz sayı. |
| `mode` | `string` | **list** gelecek verinin içeriğinin listeleme için kısa bilgiler içermesi. |
| `offset` | `integer` | Sayfalama yapısında her yenilemede kaç verinin yükleneceğini belirtir. |
