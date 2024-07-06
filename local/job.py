import pandas as pd
from sqlalchemy import create_engine

# Percorsi dei file CSV (aggiusta i percorsi in base alla tua struttura delle directory locali)
tedx_dataset_path = "../dataset/final_list.csv"
details_dataset_path = "../dataset/details.csv"
images_dataset_path = "../dataset/images.csv"
related_videos_path = "../dataset/related_videos.csv"
tags_dataset_path = "../dataset/tags.csv"

tedx_dataset = pd.read_csv(tedx_dataset_path, quotechar='"', escapechar='\\')
details_dataset = pd.read_csv(details_dataset_path, quotechar='"', escapechar='\\')
images_dataset = pd.read_csv(images_dataset_path, quotechar='"', escapechar='\\')
related_video_dataset = pd.read_csv(related_videos_path, quotechar='"', escapechar='\\')
tags_dataset = pd.read_csv(tags_dataset_path)

# Esempio di passaggi di elaborazione (adatta in base alle tue esigenze)
# Seleziona colonne, unisci dataset, filtra, aggrega, ecc.
tedx_dataset = tedx_dataset[['id', 'title', 'url']]

details_dataset = details_dataset.rename(columns={'id': 'id_ref'})
tedx_dataset = tedx_dataset.merge(details_dataset[['id_ref', 'description', 'duration', 'publishedAt']], left_on='id', right_on='id_ref', how='left').drop(columns=['id_ref'])

images_dataset = images_dataset.rename(columns={'id': 'id_ref', 'url': 'image_url'})
tedx_dataset = tedx_dataset.merge(images_dataset[['id_ref', 'image_url']], left_on='id', right_on='id_ref', how='left').drop(columns=['id_ref'])

# Elabora il dataset dei video correlati
related_video_dataset = related_video_dataset.rename(columns={'id': 'id_from', 'related_id': 'id_related', 'title': 'title_related'})
tedx_dataset = tedx_dataset.merge(related_video_dataset, left_on='id', right_on='id_from', how='left').drop(columns=['id_from'])

# Raggruppa i tag
tags_dataset_current = tags_dataset.groupby('id').agg({'tag': lambda x: list(x)}).reset_index().rename(columns={'tag': 'tag_current'})
tedx_dataset = tedx_dataset.merge(tags_dataset_current, left_on='id', right_on='id', how='left')

# Filtra i dataset
tedx_dataset = tedx_dataset[tedx_dataset['id_related'].notnull()]

tags_dataset_related = tags_dataset.groupby('id').agg({'tag': lambda x: list(x)}).reset_index().rename(columns={'tag': 'tag_related'})
tedx_dataset = tedx_dataset.merge(tags_dataset_related, left_on='id_related', right_on='id', how='left').rename(columns={'id_x': 'idref'}).drop(columns=['id_y'])

tedx_dataset_filtered = tedx_dataset[tedx_dataset['tag_related'].notnull()]

# Concatenare le liste in stringhe per permettere il raggruppamento
tedx_dataset_filtered.loc[:, 'tag_current'] = tedx_dataset_filtered['tag_current'].apply(lambda x: ','.join(x) if isinstance(x, list) else x)
tedx_dataset_filtered.loc[:, 'tag_related'] = tedx_dataset_filtered['tag_related'].apply(lambda x: ','.join(x) if isinstance(x, list) else x)
tedx_dataset_filtered.loc[:, 'id_related'] = tedx_dataset_filtered['id_related'].apply(lambda x: ','.join(map(str, x)) if isinstance(x, list) else x)
tedx_dataset_filtered.loc[:, 'title_related'] = tedx_dataset_filtered['title_related'].apply(lambda x: ','.join(x) if isinstance(x, list) else x)

tedx_grouped = tedx_dataset_filtered.groupby(['idref', 'title', 'url', 'tag_current']).agg({
    'id_related': lambda x: list(x),
    'title_related': lambda x: list(x),
    'tag_related': lambda x: list(x)
}).reset_index()

tedx_grouped = tedx_grouped.rename(columns={'idref': '_id'})

# Concatenare le liste in stringhe per permettere l'inserimento nel database
tedx_grouped.loc[:, 'id_related'] = tedx_grouped['id_related'].apply(lambda x: ','.join(map(str, x)) if isinstance(x, list) else x)
tedx_grouped.loc[:, 'title_related'] = tedx_grouped['title_related'].apply(lambda x: ','.join(x) if isinstance(x, list) else x)
tedx_grouped.loc[:, 'tag_related'] = tedx_grouped['tag_related'].apply(lambda x: ','.join(x) if isinstance(x, list) else x)

csv_filename = 'processed_data.csv'
tedx_grouped.to_csv(csv_filename, index=False)

print(f"Dati salvati con successo in '{csv_filename}'!")



# Configura il database locale SQLite
#db_name = 'processed_data.db'
#table_name = 'tedx_grouped'
# engine = create_engine(f'sqlite:///{db_name}')

# Salva i dati elaborati nel database locale
#tedx_grouped.to_sql(table_name, con=engine, if_exists='replace', index=False)

#print("Operazione completata con successo!")